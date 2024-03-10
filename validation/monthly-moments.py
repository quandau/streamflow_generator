'''Makes boxplots of bootstrapped historical monthly flows (pink) and synthetic
monthly flows (blue) as well as their means and standard deviations at
Marietta. Also plots p-values from rank-sum test for differences in the median
between historical and synthetic flows and from Levene's test for differences
in the variance between historical and synthetic flows. The site being plotted
can be changed on line 76.'''

from __future__ import division
import numpy as np 
import matplotlib
import matplotlib.pyplot as plt
import pandas as pd 
import seaborn as sns
from scipy import stats
import os

# https://justgagan.wordpress.com/2010/09/22/python-create-path-or-directories-if-not-exist/
def assure_path_exists(path):
    '''Creates directory if it doesn't exist'''
    dir = os.path.dirname(path)
    if not os.path.exists(dir):
        os.makedirs(dir)
                
assure_path_exists(os.getcwd() + '/figures/')

def init_plotting():
    '''Sets plotting characteristics'''
    sns.set_style('whitegrid')
    plt.rcParams['figure.figsize'] = (12, 12)
    plt.rcParams['font.size'] = 15
    plt.rcParams['font.family'] = 'Arial'
    plt.rcParams['axes.labelsize'] = 1.1*plt.rcParams['font.size']
    plt.rcParams['axes.titlesize'] = 1.1*plt.rcParams['font.size']
    plt.rcParams['legend.fontsize'] = plt.rcParams['font.size']
    plt.rcParams['xtick.labelsize'] = plt.rcParams['font.size']
    plt.rcParams['ytick.labelsize'] = plt.rcParams['font.size']

init_plotting()

def set_box_color(bp, color):
    '''Sets colors of boxplot elements'''
    plt.setp(bp['boxes'], color=color)
    plt.setp(bp['whiskers'], color=color, linestyle='solid')
    plt.setp(bp['caps'], color=color)
    plt.setp(bp['medians'], color='k')

# thanks to http://stackoverflow.com/questions/16592222/matplotlib-group-boxplots
def boxplots(syn, hist, xticks=True, legend=True, loc='upper right'):
  '''Makes boxplots'''
  # bpl = boxplots of synthetic data, bpr = boxplots of bootstrapped historical data
  bpl = plt.boxplot(syn, positions=np.arange(1,13)-0.15, sym='', widths=0.25, patch_artist=True)
  bpr = plt.boxplot(hist, positions=np.arange(1,13)+0.15, sym='', widths=0.25, patch_artist=True)
  set_box_color(bpl, 'yellowgreen')
  set_box_color(bpr, 'deeppink')

  plt.plot([], c='yellowgreen', label='Synthetic')
  plt.plot([], c='deeppink', label='Historical') # remember means and stdevs here are bootstrapped
  plt.gca().xaxis.grid(False)
  plt.gca().yaxis.grid(False)
  
  if xticks:
    points = range(1,13,13)
    plt.gca().set_xticks(points)
    plt.gca().set_xticklabels(points)
  else:
    plt.gca().set_xticks([])
  plt.gca().set_xlim([0,13])

  if legend:
    plt.legend(ncol=2, loc=loc)

  plt.locator_params(axis='y', nbins=5)

# Make statistical validation plots of monthly moments for Marietta
space = ['real','log']
legend_loc = ['upper right','lower left']
site = 'Panne'
H = np.loadtxt('historical/' + site + '-monthly.csv', delimiter=',') # n_historical_years x 12
S = np.loadtxt('synthetic/' + site + '-100x100-monthly.csv', delimiter=',') # n_realizations x 12*n_synthetic_years
S = S.reshape((np.shape(S)[0],int(np.shape(S)[1]/12),12)) # n_realizations x n_synthetic_years x 12
for j in range(2):    
    # j = 0: real-space, j=1: log-space
    if j == 1:
        H = np.log(H)
        S = np.log(S)
    
    N = H.shape[0]
    num_resamples = np.shape(S)[0]
    r = np.random.randint(N, size=(N, num_resamples))
    
    fig = plt.figure()
    # Boxplot of monthly totals from n_realizations*n_synthetic_years and all historical years
    ax = fig.add_subplot(5,1,1)
    boxplots(S.reshape((np.shape(S)[0]*np.shape(S)[1],12)), H, xticks=False, legend=True, loc=legend_loc[j])
    if j == 0:
        ax.set_ylabel('Q (m$\mathregular{^3}\!$/month)')
    else:
        ax.set_ylabel('Log Space Q\n log(m$\mathregular{^3}\!$/month)')
    
    # Monthly means from n_realizations of n_synthetic_years and n_realizations of bootstrapped historical years
    ax = fig.add_subplot(5,1,2)
    boxplots(S.mean(axis=1), H[r].mean(axis=0), xticks=False,  legend=False)
    ax.set_ylabel('$\hat{\mu}_Q$')
    
    # Monthly standard deviations across n_realizations of n_synthetic_years and n_realizations of bootstrapped historical years
    ax = fig.add_subplot(5,1,3)
    boxplots(S.std(axis=1), H[r].std(axis=0),  xticks=False,  legend=False)
    ax.set_ylabel('$\hat{\sigma}_Q$')
    
    # non-parametric hypothesis tests for monthly medians using Wilcoxon rank-sum test
    # and for monthly variances using Levene's test
    rank_pvals = np.zeros(12)
    levene_pvals = np.zeros(12)
    for i in range(12):
      rank_pvals[i] = stats.ranksums(H[:,i], S.reshape((np.shape(S)[0]*np.shape(S)[1],12))[:,i])[1]
      levene_pvals[i] = stats.levene(H[:,i], S.reshape((np.shape(S)[0]*np.shape(S)[1],12))[:,i])[1]
    
    ax = fig.add_subplot(5,1,4)
    ax.bar(np.arange(1,13)-0.4, rank_pvals, facecolor='khaki', edgecolor='None')
    ax.set_xlim([0,13])
    ax.plot([0,14],[0.05,0.05], color='none')
    ax.set_xticks([])
    #ax.set_yticks([])
    ax.set_ylabel('Rank-sum $p$')
    
    ax = fig.add_subplot(5,1,5)
    ax.bar(np.arange(1,13)-0.4, levene_pvals, facecolor='palegreen', edgecolor='None')
    #ax.set_yticks([])
    ax.set_xlim([0,13])
    ax.plot([0,14],[0.05,0.05], color='none')
    ax.set_xlabel('Months')
    ax.set_ylabel('Levene $p$')
    
    if j == 0:
        fig.suptitle('Real Space at ' +  site)
    else:
        fig.suptitle('Log Space at ' +  site )
    
    fig.tight_layout()
    fig.savefig('figures/boxplots_&_pvalues_' + space[j] + '_' + site + '.pdf')
        
    fig.clf()
