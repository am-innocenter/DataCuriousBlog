---
title: "Data Mining and Analysis using rtweet package"
author: "Innocenter Amima"
date: 2019-09-08T18:13:14-05:00
output: html_document
categories: ["Data Mining", "NLP"]
tags: ["Data Mining", "NLP"]
thumbnail: /images/uniqWords.png
draft: yes
---



# Census 2019 in Kenya

The 8<sup>th</sup> 2019 Population and Housing Census started from the night of 24/25th August 2019 and ended on 31st August 2019. 

Census involved counting of people within the border of Kenya at a specific time. Census is an important process for the Govenrment as it provides evidence for proper planning and resource allocation, policy formulation and targeting of development plans. You can read more about the census [here](https://www.knbs.or.ke/get-ready-to-be-counted/) and [here](https://www.standardmedia.co.ke/business/article/2001338117/what-you-need-to-know-about-2019-census)

## Objectives

Here we shall 

1. Perform data mining using `rtweet` package. 
2. Determine unique words in #Censuskenya2019 tweets.
3. Identify top user accounts in #Censuskenya2019 tweets.
4. Plot time series of tweets including #Censuskenya2019.


Loading packages

```{r, message=FALSE}
require(rtweet) #twitter mining. All you need is a Twitter account (user name and password)
library(ggplot2) #plotting
library(dplyr) #pipes  tidyverse
#require(tidytext) # text mining
library(stopwords)

theme_set(theme_classic()) #setting theme to classic()

```
## Data Mining

> I decided to use `rtweet` given that it has more functionality compared to other twitter APIS like `twitteR`, `streamR`. 

Kindly note the tweets harvested are based on who I follow on Twitter - it is a sample of what people are tweeting about #Censuskenya2019.



```{r, include=TRUE, message=FALSE}
censusTweets <- search_tweets(q="#Censuskenya2019",n=10000, include_rts = FALSE, lang='en')

censusKE <- censusTweets #creating a copy

#glimpse(censusKE)


```

The function `search_tweet()` returns tweets for the past 6-9 days. Unfortunately, I do not have a premium account - if you do try using `search_30day()` and the function requires env_name.

```{r, include=TRUE}
head(censusKE$text) #Top Tweet Unique Words

```

## Data Cleaning, Analysis and Visualization

When tweeting people use connectors and other wordss.  `tinytex` package has a function known as `stop_words()` that has three lexicons for English stop words. Below are some stop words


```{r}
head(stop_words)
```

We use `unnest_tokens()` from `tidytxt` package
to convert any text from upper to lower case, remove punctuation, add unique ID. We clean the data, convert all the text to lower case and remove stop words



```{r}

censusKE %>%
  dplyr::select(text) %>%
  unnest_tokens(Words, text) %>%
  filter(!Words %in% stop_words$word) %>%
  count(Words, sort=TRUE)

```

https appear as the 2nd highest word in #Censuskenya2019 - these represents links shared and we shall remove the https links from the text. Find and replace functions in base R include:

1. `sub(pattern, replacement, text)` replaces ONLY the first match in each element of a text vector.
2. `gsub(pattern, replacement, text)` replacess ALL the matching patterns of a text vector.  



```{r}

censusKE$strpWords <- gsub("https.*", "", censusKE$text) #removing https.* links

```

Base R has various functions that are used for regular expression and they achieve different outcomes. A very gentle introduction to regular expression has been done by Jon Calder as a course on Swirl(). Installation can be done by either using


```
library(swirl)
install_course("Regular Expressions")
swirl()
```
or alternatively downloading the latest version directly from Github 

`install_course_github("jonmcalder", "Regular_Expressions")`


### Unique words in #Censuskenya2019 tweets

```{r}

censusKE %>%
  dplyr::select(strpWords) %>%
  unnest_tokens(word, strpWords) %>%
  filter(!word %in% stop_words$word) %>%
  count(word, sort = TRUE) %>%
  top_n(20) %>%
  ggplot(censusKE, mapping =  aes(reorder(word, n), n)) +
    geom_bar(stat = 'identity', aes(fill=word), show.legend = FALSE) +
    coord_flip()+
    labs(title = "Count of unique words in #Censuskenya2019 tweets ", x="Unique Words", y="Count")


```

I was expecting to see _KNBS_ : it is ranked number 3 on the list. _Censusandbig4_ agenda ranks at the top 5. Politician names such as _Uhuru, Raila, Ruto_ are among the top 20 unique words being tweeted under the hashtag. _Enumerators_ were hired to perform this _excercise_ and hence these two words are among the top 20 unique words. However, a _mobile number_ is among the top 20 words - am not sure if it is a hot line for census?  


### Top users in #Censuskenya2019 tweets

`user_data()` returns information of the users including screen names, location, creation time, description...


```{r}
users <- users_data(censusKE)
users %>%
  dplyr::select(location) %>%
  unnest_tokens(Location, location) %>%
  count(Location, sort =TRUE) %>%
  top_n(10) %>%
  ggplot(users, mapping = aes(reorder(Location, n), n)) +
    geom_bar(stat = 'identity', aes(fill=Location), show.legend = FALSE) + 
    coord_flip() +
    labs(title = "Location of users in #Censuskenya2019 tweets", x="Location", y="Count") 
  

```
Most users were tweeting #Censususkenya2019 while in Kenya -especially Nairobi. 


```{r}

users %>% 
  dplyr::select(screen_name) %>%
  count(screen_name, sort = TRUE) %>%
  top_n(15) %>%
  ggplot(users, mapping = aes(reorder(screen_name, n), n)) +
    geom_bar(stat = 'identity', aes(fill=screen_name), show.legend = FALSE)  +
    labs(title="Top users in #Censuskenya2019 tweets", x="Screen Names", y="Count")+  
    coord_flip()



```

I was expecting KNBS account to be among the top looks like they've not been active in #Censuskenya2019 tweets.  

### Users with verified account in #Censuskenya2019 tweets.

```{r}
table(users$verified)
```

Only 15 user accounts are veified in the `users` data object.

```{r}

users %>%
  count(verified, sort=TRUE) %>%
  mutate(perc = n * 100/nrow(users)) ->verified.users


ggplot(verified.users, aes(x="", y=perc, fill=verified))+
  geom_bar(width =1, stat = 'identity') +
  coord_polar("y", start=0)+
  labs(title = "Count of verified accounts in #Censuskenya2019 tweets")+
  geom_text(aes(y=(0.67*perc), label=sprintf("%0.0f%%", round(perc,2))), color="white")+
  theme_void()

```


### Time series of #Censuskenya2019 tweets

```{r}

ts_plot(censusKE, by="days")


```

From the time series plot a lot of activity is seen on the last day of Census 2019 in Kenya i.e between 30<sup>th</sup> and 31<sup>st</sup> of August 2019.

