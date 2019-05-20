# LaLoop for iOS
LaLoop is an iOS application used to display upcoming music album release dates.

## Version 1.0.x
Download LaLoop on the [App Store](https://itunes.apple.com/us/app/laloop/id1461729494?mt=8)

## Support
If you're having any difficulties with the application, feel free to contact me at danielbogomazov@gmail.com _or_ by [creating a new issue](https://github.com/danielbogomazov/LaLoop-iOS/issues). LaLoop is developed and maintained by one person - replies may not be immediate.

## Development Contribution Note
- If the JSON from the apollo webscraper contains the month and year but not the day for the release date of the recording, we set the day to 01. To create a distinction between these dates and release dates _actually_ released on the first of the month, we use the following standard:

  - **IMPORTANT** : The standard we use for this situation is to set the date in the db as ([1999 + YYYY]-MM-01)
    - Example: A recording released on September 2018 without a day will be stored as 4017-09-01
    - Conversion back will be handled on the client-side 
    - Be aware that this is temporary - future versions will use a singular integer format instead
