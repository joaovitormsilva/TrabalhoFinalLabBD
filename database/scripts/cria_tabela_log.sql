CREATE TABLE LOG_TABLE (
    userid NUMBER,
    timestamp DATE DEFAULT SYSDATE,
    message VARCHAR2(4000),
    CONSTRAINT fk_userid FOREIGN KEY (userid) REFERENCES users(userid)
);
