## Overview

Welcome! This repository contains all materials from the Canadian Ecological Forecasting Initiative short course on Forecasting for Decision-Making: An Epidemiological & Ecological Perspective. The course took place at the Fields Institute in Toronto, ON from July 24th - 28th 2023.

In the spirit of having this course be as open as possible, we have put all the course materials here on this GitHub page, including lectures, exercises and forecast modelling materials for three case studies: Infectious Disease Control, Fisheries Management, Water Quality Monitoring. For a description of the course's overall objectives, please see [here](http://www.fields.utoronto.ca/activities/23-24/forecasting).

However, please note that the content here does not all belong exclusively to CEFI. CEFI-specific content presented here is governed by a CC-BY 4.0 licence, but all other content herein is owned by it's original creator and CEFI does not hold rights or permissions. 

For any questions about the course or about this repository please email [k.bodner@mail.utoronto.ca](k.bodner@mail.utoronto.ca). 

[![CC BY 4.0][cc-by-shield]][cc-by]

This work is licensed under a
[Creative Commons Attribution 4.0 International License][cc-by].

[![CC BY 4.0][cc-by-image]][cc-by]

[cc-by]: http://creativecommons.org/licenses/by/4.0/
[cc-by-image]: https://i.creativecommons.org/l/by/4.0/88x31.png
[cc-by-shield]: https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg

## How to Use This Repository

All code and documentation herein is free to use! If you were unable to make it to the course in person, or simply want to go through this material on your own time, please feel free. This repository is structured into 3 main sections.

### Lectures

First, is the `Lectures` folder, where the various lecture materials can be found for the course. These lectures were recorded, and the recording videos can be found on the [EFI YouTube channel](https://youtube.com/playlist?list=PLmpgJtGjCb06k0MMg6WFPbVIQq01O0K5X&si=VhCaBp1H4-AksiMK).

![first-slide](./Figs/slide-1.png)

Here is the course schedule. We suggest you roughly follow along with the order of lectures here. 

#### Schedule

|      Time Slots       |     |                                      |                                                                             Monday                                                                              |                                                                   Tuesday                                                                   |                                                                               Wednesday                                                                                |                                                           Thursday                                                           |                                                                 Friday                                                                  |
|:-------:|---------|:-------:|:------:|:------:|:------:|:------:|:------:|
| 9:00 <br>-<br> 10:00  |     |              Lecture 1               | Topic(s): <br>(1) Introductions & Schedule Overview;<br> <br>(2) Introduction to Forecasting<br><br>Lead(s): <br>(1) KB, CRF & Instructors; <br>(2) Mike Dietze |                                    Topic: <br>Bayesian Analysis - Part 2<br><br>Instructor: Mike Dietze                                     |                                                       Topic: <br>Model Assessment<br><br>Instructor: Mike Irvine                                                       |        Topic:<br>Delivering Forecasting Models to Decision Makers<br><br>Instructor: Colin Daniel and Alex Filazzola         |                                       Topic: <br>OCAP Training Part 1<br><br><br>Instructor: First Nations Information Governance Centre                      |
| 10:00 <br>- <br>10:20 |     |             Coffee Break             |                                                                                                                                                                 |                                                                                                                                             |                                                                                                                                                                        |                                                                                                                              |                                                                                                                                         |
| 10:20 <br>- <br>11:20 |     |              Lecture 2               |                                        Topic: <br>Introduction to the Modelling Landscape<br><br>Instructor: Irena Papst                                        |                                  Topic: <br>Reproducibility & Transparency<br><br>Instructor: Mike Irvine                                   | Topic: <br>Combining Fish Population Forecasting with Fisheries Management:<br>an Introduction to Management Strategy Evaluation (MSE)<br><br>Instructor: Brooke Davis | Topic:<br>Experiences Building Collaborations and Bridging Communication<br><br>Instructor: Brooke Davis + Other Instructors | (1) Group Work:<br>Finalize Presentation <br><br> (2) Overview of NEON Ecological Forecasting Challenge <br><br> Lead: (2) Quinn Thomas |
| 11:20 <br>- <br>11:30 |     |                Break                 |                                                                                                                                                                 |                                                                                                                                             |                                                                                                                                                                        |                                                                                                                              |                                                                                                                                         |
| 11:30 <br>- <br>12:30 |     | Extra Practice <br>or <br>Lecture 3: |                                              Topic: <br>Bayesian Analysis - Part 1<br><br>Instructor: Mike Dietze                                               |                                           Exercise 2:<br>Paired Coding <br><br>Lead: Mike Dietze                                            |                                [Exercise 3:<br>MSE Exercise](https://mdmazur.shinyapps.io/ToyGroundfishMSE/) <br><br>Lead: Brooke Davis                                |                           Topic:<br> Decision Analysis in Health <br><br>Instructor: Beate Sander                            |                                     Group Work: <br>Finalize Presentation <br><br> Closing Remarks                                      |
|  12:30<br>- <br>1:30  |     |                Lunch                 |                                                                                                                                                                 |                                                                                                                                             |                                                                                                                                                                        |                                                                                                                              |                                                                                                                                         |
|  1:30 <br>- <br>3:00  |     | Extra Practice <br>or <br>Lecture 3: |                                   Exercise 1: <br>Introduction to Bayesian Analysis<br><br>Lead(s): Mike Dietze + Mike Irvine                                   | Topic(s):<br>(1) Code Review Example;<br>(2) Propagating, Analyzing, &<br>Reducing Uncertainty<br><br>Instructor: Mike Dietze + Irena Papst |                                                                               Group work                                                                               |             Exercise 4: <br>Writing Lay Summaries Exercise<br><br>Lead: Korryn Bodner and Carina Rauen Firkowski             |                                                 Group Project Presentations <br>Part 1                                                  |
|  3:00<br>- <br>3:20   |     |             Coffee Break             |                                                                                                                                                                 |                                                                                                                                             |                                                                                                                                                                        |                                                                                                                              |                                                                                                                                         |
|   3:20<br>-<br>5:30   |     |              Group Work              |                        Case Study Introductions (30 mins)<br><br>Case Study Overviews (in small groups)<br><br>Lead(s): All Instructors                         |                                                                 Group work                                                                  |                                                                               Group work                                                                               |                                                          Group work                                                          |                                      Group Project Presentations <br>Part 2 <br><br> End at 3:50pm                                      |
|                       |     |                                      |                                                                                                                                                                 |                                                                                                                                             |                                                                                                                                                                        |                                                                                                                              |                                                                                                                                         |
|  6:00<br>- <br>8:00   |     |                                      |                                                                                                                                                                 |                                                                                                                                             |                                                                                                                                                                        |                                                         Group Dinner                                                         |                                                                                                                                         |

### Exercises

There are a series of exercises in the `Exercises` folder for you to work through. Instructions are in the `README_EXERCISES.md` file in that directory for how to make use of those. 

There are a number of exercises that span a couple of programming approaches to the current course content. 

### Case Studies

Perhaps most importantly, we have our four case studies. A focal point of this course is having students take a case study of interest, and work on building and expanding a forecast for a focal system. In this iteration of the course there are four case studies, one on fisheries, one on water quality, and two on COVID-19. Each of the COVID-19 case studies are from different locations (Ontario and BC respectively) and take slightly different approaches. 

There are extensive documentation for each of the case studies in their respective folders, along with troubleshooting tips. Please take the time to read through each case study before starting, as each of them have slightly different software requirements. During the in-person version of this course, each case study had two teams of four students working on each one. They have tackled some of the "Decision making problems" that the instructors suggested as ways the models could be extended. You're welcome to look through their code and results as examples of how each group chose to tackle the problem. 
