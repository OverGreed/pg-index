-- No index
DROP TABLE IF EXISTS test_no_index;

CREATE TABLE test_no_index(username varchar(40) NOT NULL, email varchar(255));

INSERT INTO test_no_index(username, email)
  SELECT substr(md5(random()::text), 0, 25), substr(md5(random()::text), 0, 25)
  FROM generate_series(1,2000000) as s(id)
  ORDER BY random();
INSERT INTO test_no_index (username, email) VALUES ('username', 'email@email.com');
INSERT INTO test_no_index (username, email) VALUES ('username', 'Email@email.com');

SELECT * FROM test_no_index limit 10;

EXPLAIN SELECT * FROM test_no_index WHERE username = 'username';

-- Basic indexes

DROP TABLE IF EXISTS test_with_index;

CREATE TABLE test_with_index(username varchar(40) NOT NULL, email varchar(255));
CREATE INDEX ON test_with_index(username);
CREATE INDEX ON test_with_index(email);

INSERT INTO test_with_index(username, email)
  SELECT substr(md5(random()::text), 0, 25), substr(md5(random()::text), 0, 25)
  FROM generate_series(1,2000000) as s(id)
  ORDER BY random();
  

INSERT INTO test_with_index (username, email) VALUES ('username', 'email@email.com');
INSERT INTO test_with_index (username, email) VALUES ('username', 'Email@email.com');

select * from users join post on post.user_id = users.id
users(id, username, status)

post(id, user_id, category, title, last_update_by_id)

EXPLAIN SELECT * FROM test_with_index WHERE username = 'username';
EXPLAIN SELECT * FROM test_with_index WHERE email LIKE 'email%';
EXPLAIN SELECT * FROM test_with_index WHERE email ILIKE 'email';
EXPLAIN SELECT * FROM test_with_index WHERE lower(email) = 'email@email.com';

-- Unique

DROP TABLE IF EXISTS test_with_uniq;
CREATE TABLE test_with_uniq(username varchar(40) NOT NULL, email varchar(255));
CREATE UNIQUE INDEX ON test_with_uniq(username) WHERE username IS NOT NULL;

INSERT INTO test_with_uniq (username, email) VALUES ('username', 'email@email.com');
INSERT INTO test_with_uniq (username, email) VALUES ('username', 'Email@email.com');

EXPLAIN SELECT * FROM test_with_uniq WHERE username = 'username';

-- Multicolumn Indexes

DROP TABLE IF EXISTS test_with_multi;
CREATE TABLE test_with_multi(username varchar(40) NOT NULL, email varchar(255));
CREATE INDEX ON test_with_multi(username, email);
INSERT INTO test_with_multi (username, email) VALUES ('username', 'gmail.com');
INSERT INTO test_with_multi (username, email) VALUES ('Username', 'test@test.com');

EXPLAIN SELECT * FROM test_with_multi WHERE username = 'username';
EXPLAIN SELECT * FROM test_with_multi WHERE username = 'username' and email = 'test@test.com';
EXPLAIN SELECT * FROM test_with_multi WHERE email = 'test@test.com';

-- Expression indexes

DROP TABLE IF EXISTS test_with_expression;
CREATE TABLE test_with_expression(username varchar(40) NOT NULL, email varchar(255));
CREATE INDEX ON test_with_expression(lower(username));
CREATE INDEX ON test_with_expression USING gin(email gin_trgm_ops);
INSERT INTO test_with_expression (username, email) VALUES ('uSeRnAmE', 'gmail.com');
INSERT INTO test_with_expression (username, email) VALUES ('Username', 'test.com');

EXPLAIN SELECT * FROM test_with_expression WHERE username = 'username';
EXPLAIN SELECT * FROM test_with_expression WHERE lower(username) = 'username';

EXPLAIN SELECT * from test_with_expression WHERE email ILIKE 'username%';

-- Case with refs

DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS users;

CREATE TABLE users(id INTEGER PRIMARY KEY, username varchar(40));
CREATE TABLE posts(id INTEGER PRIMARY KEY, user_id INTEGER REFERENCES users(id), title varchar(255));
CREATE INDEX ON posts(user_id);

INSERT INTO users(id, username) VALUES(1, 'Serhii'); 
INSERT INTO users(id, username) VALUES(2, 'Dmytro');

INSERT INTO posts(id, user_id, title) VALUES(1, 1, 'test 1');
INSERT INTO posts(id, user_id, title) VALUES(2, 1, 'test 2');
INSERT INTO posts(id, user_id, title) VALUES(3, 2, 'test 1');
EXPLAIN SELECT posts.*, users.username FROM posts LEFT JOIN users ON users.id = posts.user_id 
WHERE posts.user_id = 1

-- Case with without refs
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS users;
CREATE TABLE users(id INTEGER PRIMARY KEY, username varchar(40));
CREATE TABLE posts(id INTEGER PRIMARY KEY, user_id INTEGER, title varchar(255));

INSERT INTO users(id, username) values(1, 'Serhii'); 
INSERT INTO users(id, username) values(2, 'Dmytro');

INSERT INTO posts(id, user_id, title) VALUES(1, 1, 'test 1');
INSERT INTO posts(id, user_id, title) VALUES(2, 1, 'test 2');
INSERT INTO posts(id, user_id, title) VALUES(3, 2, 'test 1');
EXPLAIN SELECT posts.*, users.username FROM posts LEFT JOIN users ON users.id = posts.user_id 
WHERE posts.user_id = 1