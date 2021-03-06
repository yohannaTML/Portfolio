# -*- coding: utf-8 -*-
"""House Price Prediction Using ML.ipynb

Automatically generated by Colaboratory.

Original file is located at
    https://colab.research.google.com/drive/1k0U4eCBsDeHoWPADskn2Mrn0z-IyhVWB
"""

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

from sklearn.datasets import fetch_california_housing

data = fetch_california_housing()

#Independent data
df = pd.DataFrame(data= data.data, columns = data.feature_names)
df.head()

#Dependant Data
df['Target'] = data.target

df.head()

"""Exploratory Data Analysis"""

!pip install sweetviz

import sweetviz as sv
report = sv.analyze(df)
report.show_html("./report.html")

"""Data Pre-processing

"""

#Feature Engineering

from geopy.geocoders import Nominatim

geolocator = Nominatim(user_agent = 'geoapiExercises')

geolocator.reverse("37.85"+", "+"	-122.25").raw["address"]

def location(cord):
  Latitude = str(cord[0])
  Longitude = str(cord[1])

  location = geolocator.reverse(Latitude+","+Longitude).raw["address"] #raw returns a dictionnary

  #if the values are missing replace by an empty string

  if location.get('Road') is None:
    location['Road'] = None

  if location.get('County') is None:
    location['County'] = None
  
  loc_update['Road'].append(location['Road'])
  loc_update['County'].append(location['County'])

import pickle
loc_update = {"County" : [],
              "Road" : [],
              "Neighbourhood" : []}

for i, cord in enumerate(df.iloc[:,6:-1].values):
  location(cord)
  #continuous reading our data and saving it on the go
  pickle.dump(loc_update, open('loc-update.pickle', 'wb'))

  if i%100 == 0:
    print(i)

loc_update = pickle.load(open("/content/loc-update.pickle", "rb"))

loc = pd.DataFrame(loc_update)

#add the new features to our dataframe

for i in loc-update.keys():
  df[i] = loc_update[i]

df = df.sample(axis = 0, frac = 1)
df.head()

#drop latitude, longitude and the neighbourhood columns

df.frop(labels = ["Latitude", "Longitude", "Neighbourhood"], axis = 1)
df.head()

df.info()

"""Using Classification algorithm to fill the missing categorical values"""

#applying classification algorithm ( logistic regression) to find missing Road values

missing_idx = []

for i in range(df.shape[0]):
  if df["Road"][i] is None:
    missing_idx.append(i)

#Independent Parameters
missing_Road_x_train = np.array([ [df['MedInc'][i], df['AveRooms'][i], df['AveBedrms'][i] for i in range(df.shape[0]) if i not in missing_idx])
#Dependent Parameters
missing_Road_y_train = np.array([ [df['Road'][i] for i in range(df.shape[0]) if i not in missing_idx])

missing_Road_x_test = np.array([ [df['MedInc'][i], df['AveRooms'][i], df['AveBedrms'][i] for i in range(df.shape[0]) if i not in missing_idx])

from sklearn.linear_model import SGDClassifier

#model initialization

model_1 = SGDClassifier()

#Model Training
model_1.fit(missing_Road_x_train, missing_Road_y_train)

missing_Road_y_pred = model_1.predict(missing_Road_x_test)

np.unique(missing_Road_y_pred)

#add the model back to the dataframe

for n, i in enumerate(missing_idx):
  df["Road"][i] = missing_Road_y_pred

df.info()

#Label Encoding
from sklearn.preprocessing import LabelEncoder

le = LabelEncoder

df["Road"] = le.fit_transform(df["Road"])

df.head()

"""Predicting missing County information

"""

#applying classification algorithm ( logistic regression) to find missing County values

missing_idx = []

for i in range(df.shape[0]):
  if df["Road"][i] is None:
    missing_idx.append(i)

#Independent Parameters
missing_County_x_train = np.array([ [df['MedInc'][i], df['AveRooms'][i], df['AveBedrms'][i] for i in range(df.shape[0]) if i not in missing_idx])
#Dependent Parameters
missing_County_y_train = np.array([ [df['Road'][i] for i in range(df.shape[0]) if i not in missing_idx])

missing_County_x_test = np.array([ [df['MedInc'][i], df['AveRooms'][i], df['AveBedrms'][i] for i in range(df.shape[0]) if i not in missing_idx])

from sklearn.linear_model import SGDClassifier

#model initialization

model_1 = SGDClassifier()

#Model Training
model_1.fit(missing_County_x_train, missing_County_y_train)

missing_County_y_pred = model_1.predict(missing_County_x_test)

#add the model back to the dataframe

for n, i in enumerate(missing_idx):
  df["County"][i] = missing_County_y_pred

#Label Encoding
from sklearn.preprocessing import LabelEncoder

le = LabelEncoder

df["County"] = le.fit_transform(df["County"])

df.info()

"""Understanding which model to use"""

y = df.iloc(:,-3).values
df.drop(labels=['Target'], axis = 1, inplace = True)

x = df.iloc(:,:).values

from sklearn.model_selection import train_test_split

x_train, x_test, y_train, y_test = train_test_split(x, y, test_size = 0.20, random_state = 42)

from sklearn.ensemble import RandomForestRegressor

model = RandomForestRegressor

model.fit(x_train, y_train)

#model prediction

y_pred = model.predict(x_test)

#model accuracy

from sklearn.metrics import r2_score

r2_score(y_test, y_pred)

"""#add our own data"""

inp = np.array([4.1771, 44.0, 4.920721, 1.039640, 1396.0, 2.515315, 39, 5396])

#reshape input

inp = inp.reshape((1,-1))

model.predict(inp)