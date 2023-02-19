WITH
    lastCurrencies AS (
        SELECT DISTINCT ON (id) *
        FROM currency
        ORDER BY id, updated DESC
    ),
    currencies AS (
        SELECT * FROM balance
        FULL JOIN lastCurrencies c2 on c2.id = balance.currency_id
    ),

    volumes AS (
        SELECT
            user_id,
            sum(money) AS volume,
            type AS currency_type,
            COALESCE(name, 'not defined') AS currency_name,
            COALESCE(rate_to_usd, 1) AS last_rate_to_usd

        FROM currencies
        GROUP BY user_id, type, currency_name, rate_to_usd
    )

SELECT
    COALESCE(u.name, 'not defined') as name,
    COALESCE(u.lastname, 'not defined') as lastname,
    v.currency_type AS type,
    v.volume,
    v.currency_name,
    last_rate_to_usd,
    (v.volume * last_rate_to_usd) AS total_volume
FROM "user" as u
FULL JOIN volumes v ON u.id = v.user_id
ORDER BY name DESC, lastname, currency_type
