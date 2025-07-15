```
from sqlalchemy import create_engine, MetaData, Table, select

# Replace with your actual DB connection string
engine = create_engine('mssql+pyodbc://username:password@dsn_name')

metadata = MetaData(bind=engine)

# Reflect the system views
database_principals = Table('database_principals', metadata, schema='sys', autoload_with=engine)
database_role_members = Table('database_role_members', metadata, schema='sys', autoload_with=engine)

# Aliases for clarity
dp = database_principals.alias('dp')  # User
dr = database_principals.alias('dr')  # Role
drm = database_role_members.alias('drm')

# Build the query
query = (
    select(dp.c.name.label("UserName"), dr.c.name.label("RoleName"))
    .select_from(
        dp.join(drm, dp.c.principal_id == drm.c.member_principal_id)
          .join(dr, drm.c.role_principal_id == dr.c.principal_id)
    )
    .where(dr.c.name == 'db_accessadmin')
)

# Execute the query
with engine.connect() as conn:
    results = conn.execute(query)
    for row in results:
        print(row)
```
