# LaLoop-iOS
iOS application used to display upcoming music using the [apollo webscraper](https://github.com/danielbogomazov/apollo)

## Version
Pre-alpha. Working on this application simultaneously to [apollo](https://github.com/danielbogomazov/apollo). A large change in one may affect the other greatly.

## Contribution Note
- If the JSON from the apollo webscraper contains the month and year but not the day for the release date of the recording, we set the day to 01. To create a distinction between these dates and release dates _actually_ released on the first of the month, we use the following standard:

  - **IMPORTANT** : The standard we use for this situation is to set the date in the db as ([1999 + YYYY]-MM-01)
    - Example: A recording released on September 2018 without a day will be stored as 4017-09-01
    - Conversion back will be handled on the client-side 
    
