# TimeBoxer

## Description
Basic start project for a timeboxing app.  

Implements a social login using google and a full built users registration system.  

Followed the public flutterfire auth ui tutorial and implemented a few small changes to incorporate my backend system.  

Built to be extensible using multiple design patterns such as singleton stores for user data.  

Infrastructure built to be able to switch database types by overwritting FirebaseConnector (I know this is not ideal, however this is my first time using dart/flutter, so I had difficulty thinking of a better way of overwritting static methods for the interface...)

Overwritting the object factory can allow users to create different types of objects as sub classes of ModelObject.  

The DocumentModel class was originally designed to be a mixin to use with incorporated individual model objects, however this implementation seemed overkill for my goals.  

Uses a firebase firestore database.


## Set Up
To configure it yourself, create and register a firebase app, create a database, and then a collection called 'users'.

Then, simply add to your .env file 'GOOGLE_CLIENT_ID' (or remove option from auth_gate.dart)

## Retrospective

THis was a cool project, although I will not continue and achieve full functionality as I previously wanted to.

COopared to other frameworks I've used, flutter is quite unique in how its widget system allows me to build complex and good UIs quite quickly.  

However, the weaknesses seems to be efficiency, debugging and learning curve.  

While early on it is fine and expected to have difficulties implementing the UI, errors and bugs can become quite difficult the more complex the UI becomes. THis means that while you can build a prototype quickly, maintaining and expanding a flutter app does not seem ideal, at least in my opinion, compared to other established frameworks.

Additionally, since flutter is single threaded, although it is hard to mess up using async and await statements, more complex applications may suffer some pitfalls.

## Next Steps

I plan on building this same application or some close variant to it using the RubyOnRails framework, as well as potentially building anther application using Node.js to compare each of the frameworks

## To those that might follow

THis code has little to no tests, and is not designed to be expanded until those tests are written.  

If you want to use this code, I suggest only using the backend code, and attempting to build the UI on your own as that seems where the most knowledge is not be gained in my opinion.








