+++
title = 'Datawhale-quant 笔记03 - 量化选股策略浅尝试'
date = 2024-01-24T14:56:03+08:00
draft = false
+++

```python
import baostock as bs
import pandas as pd
import matplotlib.pyplot as plt
import statsmodels.api as sm
```


```python
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
```


```python
def get_bs_df(code, list_para, start_date, end_date, frequency='d', adjustflag='3'):
    para = ','.join(list_para)
    rs = bs.query_history_k_data_plus(code,para,
    start_date=start_date, end_date=end_date,
    frequency=frequency, adjustflag=adjustflag)
    data_list = []
    while (rs.error_code == '0') & rs.next():
        data_list.append(rs.get_row_data())
    df_result = pd.DataFrame(data_list, columns=rs.fields)
    print(f'get {len(df_result)} records!')
    return df_result
    
```


```python
def get_bs_profit_data(code, year, quarter):
    profit_list = []
    rs_profit = bs.query_profit_data(code=code, year=year, quarter=quarter)
    while (rs_profit.error_code == '0') & rs_profit.next():
        profit_list.append(rs_profit.get_row_data())
    df_result = pd.DataFrame(profit_list, columns=rs_profit.fields)
    return df_result
```


```python
lg = bs.login()
```

    login success!
    


```python
code = 'sh.600000'
list_para = ['date', 'code', 'close', 'volume', 'turn', 'peTTM', 'psTTM']
start_date = '2020-01-01'
end_date = '2024-01-20'
```


```python
df_daily = get_bs_df(code, list_para, start_date, end_date)
df_profit = get_bs_profit_data(code, '2020', '1')
```

    get 984 records!
    


```python
df_profit
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>code</th>
      <th>pubDate</th>
      <th>statDate</th>
      <th>roeAvg</th>
      <th>npMargin</th>
      <th>gpMargin</th>
      <th>netProfit</th>
      <th>epsTTM</th>
      <th>MBRevenue</th>
      <th>totalShare</th>
      <th>liqaShare</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>sh.600000</td>
      <td>2020-04-25</td>
      <td>2020-03-31</td>
      <td>0.030746</td>
      <td>0.316289</td>
      <td></td>
      <td>17530000000.000000</td>
      <td>2.037777</td>
      <td></td>
      <td>29352080397.00</td>
      <td>28103763899.00</td>
    </tr>
  </tbody>
</table>
</div>




```python
# get market value and earning
df_daily['market_value'] = df_daily['close'].astype(float) * float(df_profit['liqaShare'].iloc[0])
df_daily['peTTM'] = df_daily['peTTM'].replace('', pd.NaT)
df_daily['peTTM'] = df_daily['peTTM'].astype(float)
df_daily['peTTM'] = df_daily['peTTM'].fillna((df_daily['peTTM'].shift() + df_daily['peTTM'].shift(-1)) / 2)
df_daily['earning'] = df_daily['market_value'] / df_daily['peTTM'].astype(float)
df_daily
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>date</th>
      <th>code</th>
      <th>close</th>
      <th>volume</th>
      <th>turn</th>
      <th>peTTM</th>
      <th>psTTM</th>
      <th>market_value</th>
      <th>earning</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>2020-01-02</td>
      <td>sh.600000</td>
      <td>12.4700</td>
      <td>51629079</td>
      <td>0.183700</td>
      <td>5.994733</td>
      <td>1.915555</td>
      <td>3.504539e+11</td>
      <td>5.846031e+10</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2020-01-03</td>
      <td>sh.600000</td>
      <td>12.6000</td>
      <td>38018810</td>
      <td>0.135300</td>
      <td>6.057229</td>
      <td>1.935525</td>
      <td>3.541074e+11</td>
      <td>5.846030e+10</td>
    </tr>
    <tr>
      <th>2</th>
      <td>2020-01-06</td>
      <td>sh.600000</td>
      <td>12.4600</td>
      <td>41001193</td>
      <td>0.145900</td>
      <td>5.989926</td>
      <td>1.914019</td>
      <td>3.501729e+11</td>
      <td>5.846030e+10</td>
    </tr>
    <tr>
      <th>3</th>
      <td>2020-01-07</td>
      <td>sh.600000</td>
      <td>12.5000</td>
      <td>28421482</td>
      <td>0.101100</td>
      <td>6.009155</td>
      <td>1.920164</td>
      <td>3.512970e+11</td>
      <td>5.846031e+10</td>
    </tr>
    <tr>
      <th>4</th>
      <td>2020-01-08</td>
      <td>sh.600000</td>
      <td>12.3200</td>
      <td>35240536</td>
      <td>0.125400</td>
      <td>5.922624</td>
      <td>1.892513</td>
      <td>3.462384e+11</td>
      <td>5.846030e+10</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>979</th>
      <td>2024-01-15</td>
      <td>sh.600000</td>
      <td>6.5100</td>
      <td>28694155</td>
      <td>0.097800</td>
      <td>4.938175</td>
      <td>1.074966</td>
      <td>1.829555e+11</td>
      <td>3.704921e+10</td>
    </tr>
    <tr>
      <th>980</th>
      <td>2024-01-16</td>
      <td>sh.600000</td>
      <td>6.5900</td>
      <td>53186496</td>
      <td>0.181200</td>
      <td>4.998859</td>
      <td>1.088176</td>
      <td>1.852038e+11</td>
      <td>3.704922e+10</td>
    </tr>
    <tr>
      <th>981</th>
      <td>2024-01-17</td>
      <td>sh.600000</td>
      <td>6.5300</td>
      <td>48249869</td>
      <td>0.164400</td>
      <td>4.953346</td>
      <td>1.078268</td>
      <td>1.835176e+11</td>
      <td>3.704921e+10</td>
    </tr>
    <tr>
      <th>982</th>
      <td>2024-01-18</td>
      <td>sh.600000</td>
      <td>6.5600</td>
      <td>73994422</td>
      <td>0.252100</td>
      <td>4.976102</td>
      <td>1.083222</td>
      <td>1.843607e+11</td>
      <td>3.704922e+10</td>
    </tr>
    <tr>
      <th>983</th>
      <td>2024-01-19</td>
      <td>sh.600000</td>
      <td>6.5900</td>
      <td>57640079</td>
      <td>0.196400</td>
      <td>4.998859</td>
      <td>1.088176</td>
      <td>1.852038e+11</td>
      <td>3.704922e+10</td>
    </tr>
  </tbody>
</table>
<p>984 rows × 9 columns</p>
</div>




```python
df_daily['market_value'].plot()
```




    <Axes: >




    
![png](/img/finance_03_files/finance_03_9_1.png)
    



```python
df_daily['earning'].plot()
```




    <Axes: >




    
![png](/img/finance_03_files/finance_03_10_1.png)
    


### neutralize the market value


```python
groups = df_daily.groupby('date')
groups
```




    <pandas.core.groupby.generic.DataFrameGroupBy object at 0x00000248B0E74470>




```python
# 定义一个函数来执行市值中性化
def market_neutralize(group):
    # 提取市值和收益的数据列
    market_cap = group['market_value']
    returns = group['earning']
    # 添加截距项
    X = sm.add_constant(market_cap)
    # 执行线性回归，拟合收益率与市值的关系
    model = sm.OLS(returns, X)
    results = model.fit()
    # 提取回归系数
    beta = results.params['market_value']
    # 计算市值中性化后的收益
    neutralized_returns = returns - beta * market_cap
    # 将市值中性化后的收益添加到数据框中
    group['neutralized_value'] = neutralized_returns
    return group
```


```python
neutralized_data = groups.apply(market_neutralize)
```

    C:\Users\livid\AppData\Local\Temp\ipykernel_26144\1156377993.py:1: DeprecationWarning: DataFrameGroupBy.apply operated on the grouping columns. This behavior is deprecated, and in a future version of pandas the grouping columns will be excluded from the operation. Either pass `include_groups=False` to exclude the groupings or explicitly select the grouping columns after groupby to silence this warning.
      neutralized_data = groups.apply(market_neutralize)
    


```python
neutralized_data
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th></th>
      <th>date</th>
      <th>code</th>
      <th>close</th>
      <th>volume</th>
      <th>turn</th>
      <th>peTTM</th>
      <th>psTTM</th>
      <th>market_value</th>
      <th>earning</th>
      <th>neutralized_value</th>
    </tr>
    <tr>
      <th>date</th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>2020-01-02</th>
      <th>0</th>
      <td>2020-01-02</td>
      <td>sh.600000</td>
      <td>12.4700</td>
      <td>51629079</td>
      <td>0.183700</td>
      <td>5.994733</td>
      <td>1.915555</td>
      <td>3.504539e+11</td>
      <td>5.846031e+10</td>
      <td>-0.000008</td>
    </tr>
    <tr>
      <th>2020-01-03</th>
      <th>1</th>
      <td>2020-01-03</td>
      <td>sh.600000</td>
      <td>12.6000</td>
      <td>38018810</td>
      <td>0.135300</td>
      <td>6.057229</td>
      <td>1.935525</td>
      <td>3.541074e+11</td>
      <td>5.846030e+10</td>
      <td>-0.000008</td>
    </tr>
    <tr>
      <th>2020-01-06</th>
      <th>2</th>
      <td>2020-01-06</td>
      <td>sh.600000</td>
      <td>12.4600</td>
      <td>41001193</td>
      <td>0.145900</td>
      <td>5.989926</td>
      <td>1.914019</td>
      <td>3.501729e+11</td>
      <td>5.846030e+10</td>
      <td>0.000000</td>
    </tr>
    <tr>
      <th>2020-01-07</th>
      <th>3</th>
      <td>2020-01-07</td>
      <td>sh.600000</td>
      <td>12.5000</td>
      <td>28421482</td>
      <td>0.101100</td>
      <td>6.009155</td>
      <td>1.920164</td>
      <td>3.512970e+11</td>
      <td>5.846031e+10</td>
      <td>0.000000</td>
    </tr>
    <tr>
      <th>2020-01-08</th>
      <th>4</th>
      <td>2020-01-08</td>
      <td>sh.600000</td>
      <td>12.3200</td>
      <td>35240536</td>
      <td>0.125400</td>
      <td>5.922624</td>
      <td>1.892513</td>
      <td>3.462384e+11</td>
      <td>5.846030e+10</td>
      <td>-0.000008</td>
    </tr>
    <tr>
      <th>...</th>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>2024-01-15</th>
      <th>979</th>
      <td>2024-01-15</td>
      <td>sh.600000</td>
      <td>6.5100</td>
      <td>28694155</td>
      <td>0.097800</td>
      <td>4.938175</td>
      <td>1.074966</td>
      <td>1.829555e+11</td>
      <td>3.704921e+10</td>
      <td>0.000000</td>
    </tr>
    <tr>
      <th>2024-01-16</th>
      <th>980</th>
      <td>2024-01-16</td>
      <td>sh.600000</td>
      <td>6.5900</td>
      <td>53186496</td>
      <td>0.181200</td>
      <td>4.998859</td>
      <td>1.088176</td>
      <td>1.852038e+11</td>
      <td>3.704922e+10</td>
      <td>0.000000</td>
    </tr>
    <tr>
      <th>2024-01-17</th>
      <th>981</th>
      <td>2024-01-17</td>
      <td>sh.600000</td>
      <td>6.5300</td>
      <td>48249869</td>
      <td>0.164400</td>
      <td>4.953346</td>
      <td>1.078268</td>
      <td>1.835176e+11</td>
      <td>3.704921e+10</td>
      <td>0.000000</td>
    </tr>
    <tr>
      <th>2024-01-18</th>
      <th>982</th>
      <td>2024-01-18</td>
      <td>sh.600000</td>
      <td>6.5600</td>
      <td>73994422</td>
      <td>0.252100</td>
      <td>4.976102</td>
      <td>1.083222</td>
      <td>1.843607e+11</td>
      <td>3.704922e+10</td>
      <td>0.000000</td>
    </tr>
    <tr>
      <th>2024-01-19</th>
      <th>983</th>
      <td>2024-01-19</td>
      <td>sh.600000</td>
      <td>6.5900</td>
      <td>57640079</td>
      <td>0.196400</td>
      <td>4.998859</td>
      <td>1.088176</td>
      <td>1.852038e+11</td>
      <td>3.704922e+10</td>
      <td>0.000000</td>
    </tr>
  </tbody>
</table>
<p>984 rows × 10 columns</p>
</div>




```python
neutralized_data['neutralized_value'].plot()
```




    <Axes: xlabel='date,None'>




    
![png](/img/finance_03_files/finance_03_16_1.png)
    



```python
def get_all_stock(day):
    rs = bs.query_all_stock(day=day)
    print('login respond  error_msg:'+lg.error_msg)
    data_list = []
    while (rs.error_code == '0') & rs.next():
        data_list.append(rs.get_row_data())
    df_result = pd.DataFrame(data_list, columns=rs.fields)
    return df_result
```


```python
df_all_stock = get_all_stock('2023-06-30')
df_all_stock
```

    login respond  error_msg:success
    




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>code</th>
      <th>tradeStatus</th>
      <th>code_name</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>bj.430017</td>
      <td>1</td>
      <td></td>
    </tr>
    <tr>
      <th>1</th>
      <td>bj.430047</td>
      <td>1</td>
      <td></td>
    </tr>
    <tr>
      <th>2</th>
      <td>bj.430090</td>
      <td>1</td>
      <td></td>
    </tr>
    <tr>
      <th>3</th>
      <td>bj.430139</td>
      <td>1</td>
      <td></td>
    </tr>
    <tr>
      <th>4</th>
      <td>bj.430198</td>
      <td>1</td>
      <td></td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>5729</th>
      <td>sz.399994</td>
      <td>1</td>
      <td>中证信息安全主题指数</td>
    </tr>
    <tr>
      <th>5730</th>
      <td>sz.399995</td>
      <td>1</td>
      <td>中证基建工程指数</td>
    </tr>
    <tr>
      <th>5731</th>
      <td>sz.399996</td>
      <td>1</td>
      <td>中证智能家居指数</td>
    </tr>
    <tr>
      <th>5732</th>
      <td>sz.399997</td>
      <td>1</td>
      <td>中证白酒指数</td>
    </tr>
    <tr>
      <th>5733</th>
      <td>sz.399998</td>
      <td>1</td>
      <td>中证煤炭指数</td>
    </tr>
  </tbody>
</table>
<p>5734 rows × 3 columns</p>
</div>




```python
df_all_stock
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>code</th>
      <th>tradeStatus</th>
      <th>code_name</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>bj.430017</td>
      <td>1</td>
      <td></td>
    </tr>
    <tr>
      <th>1</th>
      <td>bj.430047</td>
      <td>1</td>
      <td></td>
    </tr>
    <tr>
      <th>2</th>
      <td>bj.430090</td>
      <td>1</td>
      <td></td>
    </tr>
    <tr>
      <th>3</th>
      <td>bj.430139</td>
      <td>1</td>
      <td></td>
    </tr>
    <tr>
      <th>4</th>
      <td>bj.430198</td>
      <td>1</td>
      <td></td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>5729</th>
      <td>sz.399994</td>
      <td>1</td>
      <td>中证信息安全主题指数</td>
    </tr>
    <tr>
      <th>5730</th>
      <td>sz.399995</td>
      <td>1</td>
      <td>中证基建工程指数</td>
    </tr>
    <tr>
      <th>5731</th>
      <td>sz.399996</td>
      <td>1</td>
      <td>中证智能家居指数</td>
    </tr>
    <tr>
      <th>5732</th>
      <td>sz.399997</td>
      <td>1</td>
      <td>中证白酒指数</td>
    </tr>
    <tr>
      <th>5733</th>
      <td>sz.399998</td>
      <td>1</td>
      <td>中证煤炭指数</td>
    </tr>
  </tbody>
</table>
<p>5734 rows × 3 columns</p>
</div>




```python
random_code_list = df_all_stock['code'].sample(n=100, random_state=42)
random_code_list[:10]
```




    4200    sz.300042
    4523    sz.300382
    5039    sz.300915
    5271    sz.301176
    4570    sz.300429
    80      bj.833533
    4793    sz.300657
    5444    sz.399001
    2275    sh.688195
    4889    sz.300759
    Name: code, dtype: object




```python
df_random_stock = pd.DataFrame()
for code in random_code_list:
    df_query_profit = get_bs_profit_data(code, '2023', '1')
    df_random_stock = pd.concat([df_query_profit, df_random_stock])
df_random_stock
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>code</th>
      <th>pubDate</th>
      <th>statDate</th>
      <th>roeAvg</th>
      <th>npMargin</th>
      <th>gpMargin</th>
      <th>netProfit</th>
      <th>epsTTM</th>
      <th>MBRevenue</th>
      <th>totalShare</th>
      <th>liqaShare</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>sz.002218</td>
      <td>2023-04-29</td>
      <td>2023-03-31</td>
      <td>0.002858</td>
      <td>0.050926</td>
      <td>0.289261</td>
      <td>12106116.880000</td>
      <td>0.069248</td>
      <td></td>
      <td>1413020549.00</td>
      <td>1387097895.00</td>
    </tr>
    <tr>
      <th>0</th>
      <td>sz.301357</td>
      <td>2023-04-27</td>
      <td>2023-03-31</td>
      <td>0.044201</td>
      <td>0.354312</td>
      <td>0.651019</td>
      <td>17763133.330000</td>
      <td>1.471854</td>
      <td></td>
      <td>51000000.00</td>
      <td></td>
    </tr>
    <tr>
      <th>0</th>
      <td>sz.300499</td>
      <td>2023-04-26</td>
      <td>2023-03-31</td>
      <td>-0.003956</td>
      <td>-0.037230</td>
      <td>0.227312</td>
      <td>-5611060.330000</td>
      <td>0.883847</td>
      <td></td>
      <td>308620124.00</td>
      <td>271911172.00</td>
    </tr>
    <tr>
      <th>0</th>
      <td>sh.688269</td>
      <td>2023-04-28</td>
      <td>2023-03-31</td>
      <td>0.041665</td>
      <td>0.083434</td>
      <td>0.147126</td>
      <td>41259946.580000</td>
      <td>1.582064</td>
      <td></td>
      <td>130704000.00</td>
      <td>60475900.00</td>
    </tr>
    <tr>
      <th>0</th>
      <td>sz.301279</td>
      <td>2023-04-26</td>
      <td>2023-03-31</td>
      <td>0.007763</td>
      <td>0.069013</td>
      <td>0.141962</td>
      <td>10281710.320000</td>
      <td>0.773333</td>
      <td></td>
      <td>100000000.00</td>
      <td>23466231.00</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>0</th>
      <td>sz.300429</td>
      <td>2023-04-28</td>
      <td>2023-03-31</td>
      <td>-0.000570</td>
      <td>-0.012060</td>
      <td>0.258751</td>
      <td>-2244763.150000</td>
      <td>-0.230454</td>
      <td></td>
      <td>515261048.00</td>
      <td>375715354.00</td>
    </tr>
    <tr>
      <th>0</th>
      <td>sz.301176</td>
      <td>2023-04-27</td>
      <td>2023-03-31</td>
      <td>-0.001667</td>
      <td>-0.009401</td>
      <td>0.049233</td>
      <td>-2776984.670000</td>
      <td>0.202462</td>
      <td></td>
      <td>169066667.00</td>
      <td>41056040.00</td>
    </tr>
    <tr>
      <th>0</th>
      <td>sz.300915</td>
      <td>2023-04-26</td>
      <td>2023-03-31</td>
      <td>0.016050</td>
      <td>0.097880</td>
      <td>0.343378</td>
      <td>23510745.420000</td>
      <td>0.940146</td>
      <td></td>
      <td>90000000.00</td>
      <td>24817500.00</td>
    </tr>
    <tr>
      <th>0</th>
      <td>sz.300382</td>
      <td>2023-04-27</td>
      <td>2023-03-31</td>
      <td>0.015834</td>
      <td>0.107267</td>
      <td>0.363690</td>
      <td>31710249.410000</td>
      <td>0.351077</td>
      <td></td>
      <td>626551245.00</td>
      <td>626494545.00</td>
    </tr>
    <tr>
      <th>0</th>
      <td>sz.300042</td>
      <td>2023-04-28</td>
      <td>2023-03-31</td>
      <td>0.006159</td>
      <td>0.021261</td>
      <td>0.102368</td>
      <td>7289785.240000</td>
      <td>0.304631</td>
      <td></td>
      <td>200400000.00</td>
      <td>179535526.00</td>
    </tr>
  </tbody>
</table>
<p>82 rows × 11 columns</p>
</div>




```python
for col in ['roeAvg', 'npMargin', 'gpMargin', 'epsTTM']:
    df_random_stock[col] = df_random_stock[col].replace('', float('nan'))
    df_random_stock[col] = df_random_stock[col].astype(float)
    df_random_stock[col] = df_random_stock[col].fillna((df_random_stock[col].shift() + df_random_stock[col].shift(-1)) / 2)
    df_random_stock[col] = df_random_stock[col].ffill().bfill()
```


```python
df_random_stock.info()
```

    <class 'pandas.core.frame.DataFrame'>
    Index: 82 entries, 0 to 0
    Data columns (total 11 columns):
     #   Column      Non-Null Count  Dtype  
    ---  ------      --------------  -----  
     0   code        82 non-null     object 
     1   pubDate     82 non-null     object 
     2   statDate    82 non-null     object 
     3   roeAvg      82 non-null     float64
     4   npMargin    82 non-null     float64
     5   gpMargin    82 non-null     float64
     6   netProfit   82 non-null     object 
     7   epsTTM      82 non-null     float64
     8   MBRevenue   82 non-null     object 
     9   totalShare  82 non-null     object 
     10  liqaShare   82 non-null     object 
    dtypes: float64(4), object(7)
    memory usage: 7.7+ KB
    


```python
X_test
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>roeAvg</th>
      <th>npMargin</th>
      <th>gpMargin</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>0.016232</td>
      <td>0.046711</td>
      <td>0.133795</td>
    </tr>
    <tr>
      <th>0</th>
      <td>0.002858</td>
      <td>0.050926</td>
      <td>0.289261</td>
    </tr>
    <tr>
      <th>0</th>
      <td>-0.001427</td>
      <td>-0.014075</td>
      <td>0.426115</td>
    </tr>
    <tr>
      <th>0</th>
      <td>0.003687</td>
      <td>0.051831</td>
      <td>0.379887</td>
    </tr>
    <tr>
      <th>0</th>
      <td>-0.001023</td>
      <td>-0.017475</td>
      <td>0.372661</td>
    </tr>
    <tr>
      <th>0</th>
      <td>0.014409</td>
      <td>0.034625</td>
      <td>0.160729</td>
    </tr>
    <tr>
      <th>0</th>
      <td>0.010022</td>
      <td>0.154165</td>
      <td>0.383633</td>
    </tr>
    <tr>
      <th>0</th>
      <td>0.015091</td>
      <td>0.102811</td>
      <td>0.298783</td>
    </tr>
    <tr>
      <th>0</th>
      <td>0.007763</td>
      <td>0.069013</td>
      <td>0.141962</td>
    </tr>
    <tr>
      <th>0</th>
      <td>0.002516</td>
      <td>0.015641</td>
      <td>0.132594</td>
    </tr>
    <tr>
      <th>0</th>
      <td>0.009674</td>
      <td>0.258151</td>
      <td>0.485285</td>
    </tr>
    <tr>
      <th>0</th>
      <td>-0.007977</td>
      <td>-0.143660</td>
      <td>0.727367</td>
    </tr>
    <tr>
      <th>0</th>
      <td>0.037638</td>
      <td>0.126651</td>
      <td>0.206750</td>
    </tr>
    <tr>
      <th>0</th>
      <td>0.035024</td>
      <td>0.181232</td>
      <td>0.223076</td>
    </tr>
    <tr>
      <th>0</th>
      <td>0.020825</td>
      <td>0.106386</td>
      <td>0.279624</td>
    </tr>
    <tr>
      <th>0</th>
      <td>0.024217</td>
      <td>0.234932</td>
      <td>0.353948</td>
    </tr>
    <tr>
      <th>0</th>
      <td>0.007413</td>
      <td>0.084044</td>
      <td>0.235021</td>
    </tr>
  </tbody>
</table>
</div>




```python
X = df_random_stock[['roeAvg', 'npMargin', 'gpMargin']] # 特征因子
y = df_random_stock['epsTTM'] # 目标变量

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
scaler = StandardScaler()
X_train = scaler.fit_transform(X_train)
X_test = pd.DataFrame(scaler.transform(X_test))
model = LinearRegression()
model.fit(X_train, y_train)
print('Factor weights:', model.coef_)
y_pred = model.predict(X_test)
predicted_returns = pd.DataFrame({
    'Stock': X_test.index,
    'Predicted return': y_pred
})
selected_stocks = predicted_returns[predicted_returns['Predicted return'] > 0.1]
print('Selected stocks:', selected_stocks)
```

    Factor weights: [0.5816784  0.2429101  0.27459906]
    Selected stocks:     Stock  Predicted return
    0       0          0.550256
    1       1          0.391729
    2       2          0.451719
    3       3          0.537539
    4       4          0.390086
    5       5          0.535062
    6       6          0.728756
    7       7          0.748340
    8       8          0.329657
    9       9          0.166179
    10     10          0.868106
    11     11          0.664897
    12     12          1.249381
    13     13          1.205148
    14     14          0.881246
    15     15          1.089587
    16     16          0.447703
    


```python
y_pred
```




    array([0.55025615, 0.39172872, 0.45171871, 0.5375395 , 0.39008628,
           0.5350618 , 0.72875629, 0.74833969, 0.32965658, 0.16617911,
           0.86810565, 0.66489708, 1.24938099, 1.20514782, 0.88124623,
           1.08958659, 0.44770297])




```python
pd.Series(y_test)
```




    0    0.209028
    0    0.069248
    0    1.690382
    0    0.278836
    0    0.010221
    0    0.438135
    0    0.462125
    0    0.789891
    0    0.773333
    0    0.053418
    0   -0.210894
    0    0.056950
    0    2.125819
    0    5.535384
    0    0.398913
    0    0.309732
    0    0.421868
    Name: epsTTM, dtype: float64




```python
pd.DataFrame({'y_pred':y_pred, 'y_test':y_test, 'diff %':(y_pred-y_test)/y_test*100})
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>y_pred</th>
      <th>y_test</th>
      <th>diff %</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>0.550256</td>
      <td>0.209028</td>
      <td>163.245189</td>
    </tr>
    <tr>
      <th>0</th>
      <td>0.391729</td>
      <td>0.069248</td>
      <td>465.689574</td>
    </tr>
    <tr>
      <th>0</th>
      <td>0.451719</td>
      <td>1.690382</td>
      <td>-73.277123</td>
    </tr>
    <tr>
      <th>0</th>
      <td>0.537539</td>
      <td>0.278836</td>
      <td>92.779805</td>
    </tr>
    <tr>
      <th>0</th>
      <td>0.390086</td>
      <td>0.010221</td>
      <td>3716.517772</td>
    </tr>
    <tr>
      <th>0</th>
      <td>0.535062</td>
      <td>0.438135</td>
      <td>22.122587</td>
    </tr>
    <tr>
      <th>0</th>
      <td>0.728756</td>
      <td>0.462125</td>
      <td>57.696791</td>
    </tr>
    <tr>
      <th>0</th>
      <td>0.748340</td>
      <td>0.789891</td>
      <td>-5.260385</td>
    </tr>
    <tr>
      <th>0</th>
      <td>0.329657</td>
      <td>0.773333</td>
      <td>-57.371976</td>
    </tr>
    <tr>
      <th>0</th>
      <td>0.166179</td>
      <td>0.053418</td>
      <td>211.091981</td>
    </tr>
    <tr>
      <th>0</th>
      <td>0.868106</td>
      <td>-0.210894</td>
      <td>-511.631271</td>
    </tr>
    <tr>
      <th>0</th>
      <td>0.664897</td>
      <td>0.056950</td>
      <td>1067.510238</td>
    </tr>
    <tr>
      <th>0</th>
      <td>1.249381</td>
      <td>2.125819</td>
      <td>-41.228252</td>
    </tr>
    <tr>
      <th>0</th>
      <td>1.205148</td>
      <td>5.535384</td>
      <td>-78.228289</td>
    </tr>
    <tr>
      <th>0</th>
      <td>0.881246</td>
      <td>0.398913</td>
      <td>120.911886</td>
    </tr>
    <tr>
      <th>0</th>
      <td>1.089587</td>
      <td>0.309732</td>
      <td>251.783669</td>
    </tr>
    <tr>
      <th>0</th>
      <td>0.447703</td>
      <td>0.421868</td>
      <td>6.123947</td>
    </tr>
  </tbody>
</table>
</div>



**ps** 看得出线性回归这样预测的效果并不理想
