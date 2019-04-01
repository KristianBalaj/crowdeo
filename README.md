# README

**Dokumentácia k prvému scenáru.**
Prvým scenárom je vytvorenie účtu a možnosť prihlásenia/odhlásenia.

Celý tento prvý scenár je spravený podľa knižny railstutorial.org. Ďalej stručný popis štruktúry.

V projekte je viacero integračných testov. Pre štýly je použitý Bootstrap. Vlastné štýly sú v súbore custom.scss. Zatiaľ využívam jediný model - User.

Controllers:
- StaticPagesController
  - má na starosti views: about a home
- UsersController
  - má na starosti views: signup formulár a show user
  - stará sa o HTML post obsahujúci parametre pre nového usera
- SessionsController
  - má na starosi views: login formulár
  - stará sa o HTML post pre prihlásenie usera
  - stará sa o HTML delete pre odhlásenie usera


<!-- This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ... -->
