```
from sqlalchemy import create_engine, MetaData, Table, select

# Setup your engine
engine = create_engine("mssql+pyodbc://user:password@dsn_name")
metadata = MetaData(bind=engine)

# Reflect system tables
database_principals = Table("database_principals", metadata, schema="sys", autoload_with=engine)
database_role_members = Table("database_role_members", metadata, schema="sys", autoload_with=engine)

# Aliases
dp = database_principals.alias("dp")
dr = database_principals.alias("dr")
drm = database_role_members.alias("drm")

# Set the target username
target_user = "specific_user"

# Build query with additional filter
query = select(
    dp.c.name.label("UserName"),
    dr.c.name.label("RoleName")
).select_from(
    dp.join(drm, dp.c.principal_id == drm.c.member_principal_id)
      .join(dr, drm.c.role_principal_id == dr.c.principal_id)
).where(
    dr.c.name == "db_accessadmin",
    dp.c.name == target_user
)

# Execute
with engine.connect() as conn:
    results = conn.execute(query).fetchall()
    for row in results:
        print(row)

```
