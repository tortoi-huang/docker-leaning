
-- 在 ${POSTGRES_DB} 数据库下创建演示表与测试数据
CREATE TABLE IF NOT EXISTS public.orders (
  order_id    BIGINT PRIMARY KEY,
  user_id     BIGINT NOT NULL,
  status      VARCHAR(32) NOT NULL,
  amount      NUMERIC(12,2) NOT NULL,
  order_time  TIMESTAMP NOT NULL DEFAULT now()
);

-- CDC 建议：确保 UPDATE/DELETE 时可获取旧值
ALTER TABLE public.orders REPLICA IDENTITY FULL;

-- 一些初始数据
INSERT INTO public.orders (order_id, user_id, status, amount, order_time) VALUES
  (1, 101, 'NEW',    199.99, now()),
  (2, 102, 'PAID',   329.00, now()),
  (3, 103, 'CANCEL',  59.00, now());
