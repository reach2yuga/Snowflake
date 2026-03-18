Snowflake Dynamic Tables – Quick Notes
- Dynamic tables are a new feature in Snowflake that allow you to create tables that automatically
 update based on a defined query.
- They are useful for scenarios where you want to maintain a table that reflects 
the latest data without
    having to manually refresh it.
- Dynamic tables are created using the `CREATE DYNAMIC TABLE` statement, and they require a
    query that defines how the data should be populated.
- The query can reference other tables, views, or even other dynamic tables.
- Dynamic tables are automatically refreshed based on the defined query, and they can be
    scheduled to refresh at specific intervals.
- They can also be set to refresh on demand, allowing you to control when the data is updated.
- Dynamic tables can be used in various scenarios, such as maintaining a summary table,
    creating a materialized view, or keeping a table in sync with an external data source.
- They provide a powerful way to manage and maintain data in Snowflake, reducing the need for
    manual intervention and ensuring that your data is always up to date.   
- Dynamic tables are a great addition to Snowflake's capabilities, and they can help you
    streamline your data management processes and improve the efficiency of your data workflows.
- To create a dynamic table, you can use the following syntax:
```sqlCREATE DYNAMIC TABLE <table_name> AS
SELECT <columns>    
FROM <source_table>
WHERE <conditions>;
```

- Once the dynamic table is created, it will automatically refresh based on the defined query, and you can use it just like any other table in Snowflake.
- You can also schedule the refresh of the dynamic table using the `ALTER DYNAMIC TABLE` statement, like this:
```sqlALTER DYNAMIC TABLE <table_name>

SET REFRESH SCHEDULE = 'CRON <cron_expression>';
```
- This allows you to specify a cron expression to define when the dynamic table should be refreshed, ensuring that your data is always up to date without manual intervention.
- Additionally, you can refresh the dynamic table on demand using the `REFRESH DYNAMIC TABLE` statement:
```sqlREFRESH DYNAMIC TABLE <table_name>;
```
- This command will trigger an immediate refresh of the dynamic table, allowing you to update the data
whenever needed.
- Dynamic tables are a powerful tool for managing data in Snowflake, and they can help you automate
    data updates and ensure that your data is always current without the need for manual refreshes.
- Overall, dynamic tables are a valuable addition to Snowflake's features, providing a convenient way to maintain up-to-date data and streamline your data management processes.
