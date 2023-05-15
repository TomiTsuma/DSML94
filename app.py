import nbformat
from nbconvert.preprocessors import ExecutePreprocessor


pipeline = ['get_valid_aver_spectra.ipynb','join_lims_averaged_spectra.ipynb','get_predictions.ipynb','high_low_value_aver_outliers_filter.ipynb','Mark Outliers in Wetchem Data.ipynb','wavelet_transformation.ipynb','Train Test Validation Split.ipynb']
def app():
    for fcn in pipeline:
        print(fcn)
        filename = fcn
        with open(filename) as ff:
            nb_in = nbformat.read(ff, nbformat.NO_CONVERT)
            
        ep = ExecutePreprocessor(timeout=60000000000000, kernel_name='python3')
        nb_out = ep.preprocess(nb_in)
        print("\b")


if __name__ == "__main__":
    app()