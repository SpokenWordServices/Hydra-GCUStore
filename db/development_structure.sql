CREATE TABLE "bookmarks" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL, "url" text, "document_id" varchar(255), "title" varchar(255), "notes" text, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
CREATE TABLE "searches" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "query_params" text, "user_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "superusers" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL);
CREATE TABLE "taggings" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "tag_id" integer, "taggable_id" integer, "taggable_type" varchar(255), "created_at" datetime);
CREATE TABLE "tags" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255));
CREATE TABLE "user_attributes" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL, "first_name" varchar(255), "last_name" varchar(255), "affiliation" varchar(255), "photo" varchar(255));
CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "login" varchar(255) NOT NULL, "email" varchar(255), "crypted_password" varchar(255), "last_search_url" text, "last_login_at" datetime, "created_at" datetime, "updated_at" datetime, "password_salt" varchar(255), "persistence_token" varchar(255), "current_login_at" datetime);
CREATE INDEX "index_searches_on_user_id" ON "searches" ("user_id");
CREATE INDEX "index_taggings_on_tag_id" ON "taggings" ("tag_id");
CREATE INDEX "index_taggings_on_taggable_id_and_taggable_type" ON "taggings" ("taggable_id", "taggable_type");
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
INSERT INTO schema_migrations (version) VALUES ('20090127164730-blacklight');

INSERT INTO schema_migrations (version) VALUES ('20090127164740-blacklight');

INSERT INTO schema_migrations (version) VALUES ('20090127164750-blacklight');

INSERT INTO schema_migrations (version) VALUES ('20090428182620-blacklight');

INSERT INTO schema_migrations (version) VALUES ('20090127193406');

INSERT INTO schema_migrations (version) VALUES ('20090529161304-blacklight');

INSERT INTO schema_migrations (version) VALUES ('20090529214829');

INSERT INTO schema_migrations (version) VALUES ('20101108192527');

INSERT INTO schema_migrations (version) VALUES ('20101105214243-hydra_repository');