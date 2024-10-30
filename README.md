# Indoor-positioning
> Indoor positioning flutter app with python back-end to estimate A person location inside building. 

# How this works?

The main aim of this project is to find people position inside closed areas such as hospital, subway metro, mall shoping etc...
For achiving this, there are many ways but i implemented trilateration and AI based SVM algorithm.
For AI's inefficiencies in learning during offline phase i compelled to use trilateration algorithm wich was sufficient enough to estimated position correctly during online phase.
![trilateration genetrated by trilateration.py](/img/trilateration.png)

In above image, which is the output of trilateration_plot_maker.py, the yellow initial point is generated using centroid localization and with the help of calculating second degree equations of three intercepted circles and optimization algorithm named minimize in scipy python library the red star point(user position) is generated wihic is sufficiently accurate.


<!-- ![app beacons](/img/app-beacons.jpg) -->
<p align="center">

<img  src="/img/app-beacons.jpg" alt="drawing" width="650"/>
</p>


The main **start** button, starts scanig nearby area to find beacons of each AP(access poinnts) also **stop** pauses scaning mode.

There was four source BLE beacons (Beacons_1, Beacons_2, Beacons_3, Beacons_4) which give the specific characteristc of related area on the ground, during AI learning phase.
after finishing learning mode, a CSV file is generated which is needed for machine learning phase. the trained model is a JSON file (model.json) is uploaded through app files directory in order to predict the user current state by **find me!** button.

If you wish to go with trilateration method, just run python server(trilateration_plot_maker.py) and try to connect to server's machine bluetooth on RFCOMM socket with **connect** button.
After connection app is trying to send live RSSI beacons of four APs to server wich the location is predicted using APs initial points you have already set up in server!

This project is only created for test environment **NOT** for production.

## Contact
Mohammad Hossein mmd.hosseinnnn@gmail.com - feel free to contact me!


