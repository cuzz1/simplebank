CREATE TABLE "accounts" (
  "id" BIGSERIAL PRIMARY KEY,
  "owner" varchar NOT NULL,
  "balance" bigint NOT NULL,
  "currency" varchar NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT (now())
);

CREATE TABLE "entries" (
  "id" BIGSERIAL PRIMARY KEY,
  "account_id" bigint NOT NULL,
  "amount" bigint NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT (now())
);

CREATE TABLE "transfers" (
  "id" BIGSERIAL PRIMARY KEY,
  "from_account_id" bigint NOT NULL,
  "to_account_id" bigint NOT NULL,
  "amount" bigint NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT (now())
);

ALTER TABLE "entries" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id");

ALTER TABLE "transfers" ADD FOREIGN KEY ("from_account_id") REFERENCES "accounts" ("id");

ALTER TABLE "transfers" ADD FOREIGN KEY ("to_account_id") REFERENCES "accounts" ("id");

CREATE INDEX ON "accounts" ("owner");

CREATE INDEX ON "entries" ("account_id");

CREATE INDEX ON "transfers" ("from_account_id");

CREATE INDEX ON "transfers" ("to_account_id");

CREATE INDEX ON "transfers" ("from_account_id", "to_account_id");

COMMENT ON TABLE "accounts" IS '账户';

COMMENT ON COLUMN "accounts"."id" IS '主键';

COMMENT ON COLUMN "accounts"."owner" IS '账户所有者';

COMMENT ON COLUMN "accounts"."balance" IS '账户余额';

COMMENT ON COLUMN "accounts"."currency" IS '货币类型，比如：人民币';

COMMENT ON COLUMN "accounts"."created_at" IS '创建时间';

COMMENT ON TABLE "entries" IS '记录所有余额变化';

COMMENT ON COLUMN "entries"."id" IS '主键';

COMMENT ON COLUMN "entries"."account_id" IS '账户id，关联account的id';

COMMENT ON COLUMN "entries"."amount" IS '变化金额，可正可负';

COMMENT ON COLUMN "entries"."created_at" IS '创建时间';

COMMENT ON TABLE "transfers" IS '转账交易记录';

COMMENT ON COLUMN "transfers"."id" IS '主键';

COMMENT ON COLUMN "transfers"."from_account_id" IS '转账id';

COMMENT ON COLUMN "transfers"."to_account_id" IS '被转账id';

COMMENT ON COLUMN "transfers"."amount" IS '必须为正';

COMMENT ON COLUMN "transfers"."created_at" IS '创建时间';
