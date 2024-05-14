# Calculate statistics

This repository holds a number of scripts to calculate the statistics of a generated repository.

There are 2 Dockers defined in this:

1. A testing docker to evaluate the scripts locally
2. A CircleCI docker that can be used to evaluate a repository


# Deployment of CircleCI solution

Let GENERATED be the source generated repository.
For that repository a new repository STATISTICS has to be created.
The objective is that the CircleCI that will be deployed in the GENERATED repository will store the resulting statistics on the STATISTICS repository.

It also may be an option to use for STATISTICS a branch on the GENERATED.


# the supported statistics


Let NAMESPACE be the namespace on which the terms of GENERATED are published.


1. the number of classes published in NAMESPACE 
2. the number of properties publised in NAMESPACE 
3. the number of classes using a different namespace as NAMESPACE (external terms)
4. the number of properties using a different namespace as NAMESPACE (external terms)
5. the total number of terms (sum of the above)
6. the number of authors
7. the number of editors
8. the number of contributors
9. the total number of participants (less of equal to the sum of the above)
10. the organisations and their number of participants (grouped by their name)
11. the total number of organisations contributing
12. the number of specifications per status and per year / month (only for the aggregation)


## considerations

The statistics are calculated per specifications and as an aggregated statistic.
The aggregated statistic is not equal to the mathematical sum of the numbers of each specification specific statistic.
This is because there is an high overlap between the values between the specifications.
The aggregated statistics are therefore substantially lower than the mathematical sum.

The aggregated statistics also contain an overview per specification status.
Each status provides the number of specifications in a year and then per month.
This allows to picture a evolutionary figure.

If there is interest this aggregation could be augemented with the references to the specifications.

## limitations
These scripts are designed to run upon a GENERATED repository. 
For specifications that are listed in the standardsregisters outside this repository are not included in the overview.





