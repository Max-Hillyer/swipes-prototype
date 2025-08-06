This is a prototype of my future Swift Student Challenge submission, Swipes. <br> 
Right now, Swipes is an iOS app that uses a swiping UI and a recommendation engine I built myself to provide a help a user find a summer program for them. <br> 
As a highschooler I've found that it's a real pain to search through tons of programns to find one for me, but it doesn't have to be. <br> 
I realize that the swift student challenge is still a long ways out, but i just learned about it a couple months ago and was really eager to get started. <br> 
Swipes will continue to evolve until Feburary, when i'll submit it to Apple and shoot for distinguished winner. <br> 

#How It Works 

The recommendation engine is actually pretty uncomplicated. <br> 
Every card has a set of attributes, all of which start with a ranking of 0.5, if the user likes the program, the rating for each of those attributes is pulled closer to 1, and if the user skips the program the ratings are pulled closer to 0. <br>
Every few Swipes, the engine calculates a score for each of the remaining cards based on the rating of each attribute of the card. <br> 
Then, the engine reorders the remaining cards by their score, so the cards with a rating closer to 1 are shown before the cards closer to 0. <br> 

##Confidence 

An attributes "Confidence" functions like a multiplier. <br> 
The more a user likes a certain attribute over and over again, the higher the Confidence of that attribute. <br> 
When an attribute has a high confidence a couple helpful things happen: the attribute has more influence over the cards score, and its harder to convince the engine that the user doesnt like this attribute. <br> 

##Diversity 

While creating this prototype I ran into a curious issue. <br> 
A user might like just a few programs of one category, but then would only get programs of that category until they ran out. <br> 
I quickly realized that my engine was throwing users into feedback loops. Because of the way the engine reordered programs, the user had no opportunity to express intrest in other categories. <br> 
To solve this, I added some code to sprinkle programs from the middle and end of the program order towards the front, giving the engine a chance to learn what the user really wants, at the expense of the engine seeming perfect to brand new users. 

#Data

All my data was legally scraped from a couple of websites with summer programs. <br> 
I was able to get together a decent list but the more programs I have the better my app inherently is. <br> 
If you have any summer programs, or a list of summer programs, please reach out so I can add them and improve my app and submission. Thank You!
