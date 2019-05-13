require 'pg'
require 'bcrypt'

include BCrypt

begin

  tables_to_disable_indices = ["events", "event_attendances", "events_gender_filters", "users"]
  genders_count = 2
  events_count = 1000000
  users_count = 1000000
  attends_count = 1000000

  con = PG.connect dbname: 'crowdeo_development', user: 'postgres', password: 'password'
  
  con.exec 'TRUNCATE events CASCADE'
  con.exec 'TRUNCATE users CASCADE'
  con.exec 'TRUNCATE event_attendances CASCADE'
  con.exec 'TRUNCATE events_gender_filters CASCADE'
  
  con.exec 'TRUNCATE table1 CASCADE'
  con.exec 'TRUNCATE table2 CASCADE'
  con.exec 'TRUNCATE table3 CASCADE'
  con.exec 'TRUNCATE table4 CASCADE'
  
  con.exec "ALTER SEQUENCE event_attendances_id_seq RESTART WITH #{attends_count + 1}"
  con.exec "ALTER SEQUENCE events_gender_filters_id_seq RESTART WITH #{events_count + 1}"
  con.exec "ALTER SEQUENCE events_id_seq RESTART WITH #{events_count + 1}"
  con.exec "ALTER SEQUENCE users_id_seq RESTART WITH #{users_count + 1}"
  
  #disable trigger
  con.exec "ALTER TABLE events DISABLE TRIGGER events_count"
  
  #disable indexes for given tables
  # tables_to_disable_indices.each do |table_name|
  #   con.exec "UPDATE pg_index
  #             set indisvalid = false
  #             WHERE indrelid = (
  #               SELECT oid
  #               FROM pg_class
  #               WHERE relname='#{table_name}'
  #             );"
  #   con.exec "UPDATE pg_index
  #             SET indisready=false
  #             WHERE indrelid = (
  #               SELECT oid
  #               FROM pg_class
  #               WHERE relname='#{table_name}'
  #             );"
  # end

  # puts "Creating supplement tables"
  # con.exec "insert into table1 (id, created_at, updated_at) select i, now(), now() from generate_series(0, #{1000000}) s(i);"
  # puts "Table1 created"
  # con.exec "insert into table2 (id, created_at, updated_at) select i, now(), now() from generate_series(0, #{1000000}) s(i);"
  # puts "Table2 created"
  # con.exec "insert into table3 (id, created_at, updated_at) select i, now(), now() from generate_series(0, #{1000000}) s(i);"
  # puts "Table3 created"
  # con.exec "insert into table4 (id, created_at, updated_at) select i, now(), now() from generate_series(0, #{1000000}) s(i);"
  # puts "Table4 created"
  
  # con.exec 'BEGIN'
  # con.exec "insert into events (id, name, created_at, updated_at) values (1, 'test', '#{Time.now}', '#{Time.now}')"
  digest = Password.create('password')
  
  start_time = Time.now
  con.exec "insert into users (id, nick_name, email, gender_id, password_digest, created_at, updated_at) select i, concat('nick', i), concat(concat('nick', i), '@email.com'), floor(random() * #{genders_count}),'#{digest}', now(), now() from generate_series(0, #{users_count}) s(i);"
  
  puts "Users created, time elapsed #{Time.now - start_time} seconds"
  start_time = Time.now
  
  con.exec "insert into events (id, name, description, start_date, end_date, author_id, created_at, updated_at) select i, concat('Event ', i), concat('Description to event ', i), '2017-03-06', '2017-03-06', floor(random() * #{users_count}), now(), now() from generate_series(0, #{events_count}) s(i); "
  
  puts "Events created, time elapsed #{Time.now - start_time} seconds"
  start_time = Time.now
  
  con.exec "insert into event_attendances (user_id, event_id, created_at, updated_at) select floor(random() * #{users_count}), floor(random() * #{events_count}), now(), now() from generate_series(0, #{attends_count}) s(i);"
  
  puts "Event attendances created, time elapsed #{Time.now - start_time} seconds"
  start_time = Time.now
  
  # events with ids {0, 3, 6, ...} have gender filter male
  con.exec "insert into events_gender_filters (event_id, gender_id, created_at, updated_at) select i, 0, now(), now() from generate_series(0, #{events_count}, 3) s(i);"
  puts "Event gender filters (male) for events with id {0, 3, 6, ...} created, time elapsed #{Time.now - start_time} seconds"
  start_time = Time.now
  
  # events with ids {1, 4, 7, ...} have gender filter female
  con.exec "insert into events_gender_filters (event_id, gender_id, created_at, updated_at) select i, 1, now(), now() from generate_series(1, #{events_count}, 3) s(i);"
  puts "Event gender filters (female) for events with id {1, 4, 7, ...} created, time elapsed #{Time.now - start_time} seconds"
  start_time = Time.now
  
  # events with ids {2, 5, 8, ...} have gender filter male and female
  con.exec "insert into events_gender_filters (event_id, gender_id, created_at, updated_at) select i, 0, now(), now() from generate_series(2, #{events_count}, 3) s(i);"
  con.exec "insert into events_gender_filters (event_id, gender_id, created_at, updated_at) select i, 1, now(), now() from generate_series(2, #{events_count}, 3) s(i);"
  puts "Event gender filters (male, female) for events with id {2, 5, 8, ...} created, time elapsed #{Time.now - start_time} seconds"
  start_time = Time.now

rescue PG::Error => e

  puts e.message

ensure

  puts "Updating events_count"
  con.exec "UPDATE events_count set rows_count=(SELECT COUNT(*) FROM events)"

  puts "Enabling events count trigger"
  con.exec "ALTER TABLE events ENABLE TRIGGER events_count"

  puts "Enabling indexes"
  # disable indexes for given tables
  tables_to_disable_indices.each do |table_name|
    con.exec "UPDATE pg_index
              set indisvalid = true
              WHERE indrelid = (
                SELECT oid
                FROM pg_class
                WHERE relname='#{table_name}'
              );"
    con.exec "UPDATE pg_index
              SET indisready=true
              WHERE indrelid = (
                SELECT oid
                FROM pg_class
                WHERE relname='#{table_name}'
              );"
  end

  con.close if con

end

