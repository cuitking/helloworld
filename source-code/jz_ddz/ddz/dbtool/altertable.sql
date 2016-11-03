use ddzgame_1;

alter table role_mailinfos add mail_key varchar(30) not null default "" comment '邮件key';
alter table role_mailinfos add reason int(11) not null DEFAULT '0' comment '发放邮件的原因';
