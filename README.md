# Freibad App

## Description

The Freibad-App is a web and mobile app using Flutter. The app is used to interact with a REST-Api which reserves spots for my local public swimming pool (which is required because of Corona). After creating an account or logging in, the user can access the app. The app is separated in three tabs:
 - Codes: An overview of the user’s reservations. A reservation is made of the reservation time and date, the reservation location, the reservation status (failed, pending, successful) and the individuals of the reservation. If the reservation is successful, each user has an entry code assigned, which can be used to be verified on site. If the user wants to cancel/delete a reservation, it can be swiped away.  
- Pick: The user can choose the reservation date 15 days in advance and is given weather information for each day especially important for open-air swimming pools visits. After selecting a date, the opening times for the selected location on that day are displayed. The time slot closest to the highest temperature is highlighted. Finally, a variable number of individuals can be assigned to the reservation.
- Settings: A screen mostly used to switch between API-Services, but also displays a button to the license screen and the option to logout. 

## Experience the App

How can you explore the app?

  - Android/Apple

#### Android/Apple:
  Clone the repository and transfer the app to your phone by building the app with the Flutter Framework. While an Android based phone was used to   develop the app, the app could not be tested on an Apple device due to a lack of equipment.

#### Web with GitHub Pages
 This project is deployed on GitHub Pages. Freibad-Server and Weather-API access are intentionally blocked because APIKeys are required. You should further note that Flutter for Web is still in Beta and you might encounter some bugs related to the Framework. Chrome (based browsers) works best and is recommended for a (mostly) bug free experience.

Note: To get the full app functionality a ClimaCell API Key is recommended, to get real weather information based on your location. Further, you could setup the Freibad-Server yourself and connect it to the app.

