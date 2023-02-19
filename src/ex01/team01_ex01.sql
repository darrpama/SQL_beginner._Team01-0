insert into currency values (100, 'EUR', 0.85, '2022-01-01 13:29');
insert into currency values (100, 'EUR', 0.79, '2022-01-08 13:29');

CREATE OR REPLACE FUNCTION nearest_dt(balance_date timestamp, currency_id bigint)
RETURNS timestamp
    LANGUAGE SQL
    AS $$
    SELECT COALESCE(
        (SELECT updated FROM currency AS c
        WHERE c.id = currency_id
        AND balance_date >= c.updated
        ORDER BY c.updated DESC
        LIMIT 1),
        (SELECT updated FROM currency AS c
        WHERE c.id = currency_id
        AND balance_date < c.updated
        ORDER BY c.updated ASC
        LIMIT 1)
    ) LIMIT 1
$$;

SELECT
    COALESCE(u.name, 'not defined') as name,
    COALESCE(u.lastname, 'not defined') as lastname,
    c.name,
    money * c.rate_to_usd

FROM "user" as u
FULL JOIN balance b on u.id = b.user_id
INNER JOIN currency c on b.currency_id = c.id
    AND c.updated = nearest_dt(balance_date := b.updated, currency_id := c.id)
ORDER BY 1 DESC, 2, 3
