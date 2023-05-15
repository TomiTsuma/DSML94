import psycopg2
import pandas as pd

def get_db_cursor():
    username = "doadmin"
    password = 'yzmodwh2oh16iks6'
    host = 'db-postgresql-cl1-do-user-2276924-0.db.ondigitalocean.com'
    port = 25060
    database = 'MandatoryMetadata'
    schema = 'historical'

    conn = psycopg2.connect(host=host,database=database, user=username, password=password, port=port)
    cur = conn.cursor()
    cur.execute("SET search_path TO " + schema)

    return conn, cur

def get_valid_aver_spectra():
    conn, cur = get_db_cursor()

    spectra = pd.read_sql("SELECT metadata_id, averaged_spectra FROM spectraldata WHERE (is_finalized=True AND (passed=True AND is_active=True AND averaged=True))", con=conn)
    spectra.to_csv("outputFiles/spectraldata.csv")

    metadata = pd.read_sql("select * from mandatorymetadata m", con=conn)

    chemicals = pd.read_sql("select * from chemical", con=conn)

    metadata = metadata[['metadata_id','sample_code']]

    chemicals = chemicals[['chemical_id','chemical_name']]

    spectra = pd.merge(spectra,metadata,on="metadata_id",how="left")

    spectra.to_csv("outputFiles/spectraldata.csv")

    
