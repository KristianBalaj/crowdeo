class AddEventsCounter < ActiveRecord::Migration[5.2]
  def up
    #create events counter table
    ActiveRecord::Base.connection.execute(
        'CREATE TABLE events_count (
          rows_count BIGINT
        );')

    #create events counting procedure
    ActiveRecord::Base.connection.execute(
        "CREATE OR REPLACE FUNCTION adjust_count()
          RETURNS TRIGGER AS
        $$
        DECLARE
        BEGIN
          IF TG_OP = 'INSERT' THEN
            EXECUTE 'UPDATE events_count set rows_count=rows_count +1';
            RETURN NEW;
          ELSIF TG_OP = 'DELETE' THEN
            EXECUTE 'UPDATE events_count set rows_count=rows_count -1';
            RETURN OLD;
          END IF;
        END;
        $$
          LANGUAGE 'plpgsql';")

    #add events counting trigger to events table
    ActiveRecord::Base.connection.execute('
      CREATE TRIGGER events_count BEFORE INSERT OR DELETE ON events
      FOR EACH ROW EXECUTE PROCEDURE adjust_count();')
  end

  def down
    ActiveRecord::Base.connection.execute('DROP TABLE events_count')
    ActiveRecord::Base.connection.execute('DROP TRIGGER events_count ON events')
    ActiveRecord::Base.connection.execute('DROP FUNCTION adjust_count()')
  end
end
