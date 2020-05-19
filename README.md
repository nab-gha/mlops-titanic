Analysing Kaggle datasets using Spark ML.

[Titanic: Machine Learning from Disaster](https://www.kaggle.com/c/titanic)
copy of [Jeffwan's code](https://github.com/Jeffwan/aws-emr-titanic-ml-example) for gitops work

### Build Spark Jars

```shell
sbt clean package
```

> Note: EMR has all spark libariries and this project doesn't reply on third-party library. We don't need to build fat jars.


### Run Spark jobs

```shell
spark-submit --class com.amazonaws.emr.titanic.Titanic target/scala-2.11/titanic-survivors-prediction_2.11-1.0.jar train.csv /tmp/output/
```