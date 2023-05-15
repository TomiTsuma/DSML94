import pandas as pd
import numpy as np
import os
chemicals = ['boron', 'calcium', 'clay', 'copper', 'ec_salts',
       'exchangeable_acidity', 'iron', 'magnesium', 'manganese', 'phosphorus',
       'potassium', 'sand', 'silt', 'sodium', 'sulphur', 'zinc', 'ph']


def validateSplittingRatios():
    split_ratios = pd.DataFrame()
    validation_set = []
    training_set = []
    test_set = []
    for chemical in chemicals:
        # print(chemical)
        try:
            valid = pd.read_csv(f"D://CropNutsDocuments/DS-ML94/outputFiles/splits/{chemical}_valid_sample_codes.csv") 
            test = pd.read_csv(f"D://CropNutsDocuments/DS-ML94/outputFiles/splits/{chemical}_test_sample_codes.csv")
            train = pd.read_csv(f"D://CropNutsDocuments/DS-ML94/outputFiles/splits/{chemical}_train_sample_codes.csv")
        except Exception as e:
            print(e)
            print(chemical)
            break

        total = len(valid.index) + len(test.index) + len(train.index)

        valid_pct = ((len(valid.index) / (total)) * 100)
        test_pct = ((len(test.index) / (total)) * 100)
        train_pct = ((len(train.index) / (total)) * 100)

        validation_set.append(valid_pct)
        training_set.append(train_pct)
        test_set.append(test_pct)
    split_ratios['chemical'] = chemicals
    split_ratios['validation'] = validation_set
    split_ratios['training'] = training_set
    split_ratios['test'] = test_set

    split_ratios.to_csv("D://CropNutsDocuments/DS-ML94/outputFiles/test_protocol/splitting_ratios.csv")
        

def intersectingSamples():
    for chemical in chemicals:
        try:
            os.mkdir("D://CropNutsDocuments/DS-ML94/outputFiles/test_protocol")
        except:
            print("\b")
        valid = pd.read_csv(f"D://CropNutsDocuments/DS-ML94/outputFiles/splits/{chemical}_valid_sample_codes.csv") 

        test = pd.read_csv(f"D://CropNutsDocuments/DS-ML94/outputFiles/splits/{chemical}_test_sample_codes.csv")
        train = pd.read_csv(f"D://CropNutsDocuments/DS-ML94/outputFiles/splits/{chemical}_train_sample_codes.csv")

        valid[(valid['x'].isin(test.x.values))].to_csv("D://CropNutsDocuments/DS-ML94/outputFiles/test_protocol/valid_codes_in_test.csv")
        valid[(valid['x'].isin(train.x.values))].to_csv("D://CropNutsDocuments/DS-ML94/outputFiles/test_protocol/valid_codes_in_train.csv")
        test[(test['x'].isin(valid.x.values))].to_csv("D://CropNutsDocuments/DS-ML94/outputFiles/test_protocol/test_codes_in_valid.csv")
        test[(test['x'].isin(train.x.values))].to_csv("D://CropNutsDocuments/DS-ML94/outputFiles/test_protocol/test_codes_in_train.csv")
        train[(train['x'].isin(valid.x.values))].to_csv("D://CropNutsDocuments/DS-ML94/outputFiles/test_protocol/train_codes_in_valid.csv")
        train[(train['x'].isin(test.x.values))].to_csv("D://CropNutsDocuments/DS-ML94/outputFiles/test_protocol/train_codes_in_test.csv")


def validateOutliers():
    outlier = pd.read_csv("D://CropNutsDocuments/DS-ML94/outputFiles/outlier_spectra.csv")--
    wetchem = pd.read_csv("D://CropNutsDocuments/DS-ML94/outputFiles/lv_filtered.csv")
    
    intersecting_sample =  wetchem[(wetchem['sample_code'].isin(outlier['sample_code'].values))]
    non_intersecting_sample =  wetchem[~(wetchem['sample_code'].isin(outlier['sample_code'].values))]
    print(len(intersecting_sample.sample_code.values))
    print(len(non_intersecting_sample.sample_code.values))
    intersecting_sample.to_csv("D://CropNutsDocuments/DS-ML94/outputFiles/test_protocol/outliers_in_model.csv")
if __name__ == "__main__":
    validateSplittingRatios()
    intersectingSamples() 
    validateOutliers()   
