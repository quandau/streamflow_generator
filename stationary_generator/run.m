datadir = './../data/';

%% Realisation and Years
realisation = 5;
years = 1000;

%% Names of Stations
sites = { 'Trann.csv','Lassi.csv', 'Acis.csv','Bar_S.csv', 'Mery.csv','Nogen.csv'...,
    'Panne.csv','Cussy.csv','Stger.csv','Gurgy.csv','Aisy.csv','Brien.csv', 'Guill.csv'...,
    'Chabl.csv','Courl.csv','Mont.csv','Episy.csv','Alfor.csv','Louve.csv','Stdiz.csv'...,
    'Vitry.csv','Chalo.csv','Montr.csv','Noisi.csv','Paris.csv'};

clean_data;

%% Generate streamflow
script;

%% Write synthetic data to CSV 
csvexport(sites);
