FROM python:3.9.7
ENV PYTHONUNBUFFERED=1
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install build-essential openjdk-11-jdk zip unzip wget
RUN wget https://github.com/bazelbuild/bazel/releases/download/4.2.1/bazel-4.2.1-dist.zip
RUN mkdir bazel-4.2.1mkdir bazel-4.2.1
RUN unzip -d ./bazel-4.2.1 bazel-4.2.1-dist.zip
WORKDIR /bazel-4.2.1
RUN env EXTRA_BAZEL_ARGS="--host_javabase=@local_jdk//:jdk" bash ./compile.sh
RUN cp output/bazel /usr/local/bin

WORKDIR /

RUN apt-get -y install git

RUN git clone https://github.com/tensorflow/tensorflow
WORKDIR /tensorflow
RUN git checkout r2.8

RUN pip install -U pip six 'numpy<1.19.0' wheel setuptools mock 'future>=0.17.1'
RUN pip install -U keras_applications --no-deps
RUN pip install -U keras_preprocessing --no-deps

RUN bazel build --config=opt -c opt //tensorflow/tools/pip_package:build_pip_package
RUN ./bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
RUN pip install /tmp/tensorflow_pkg/tensorflow-2.8.0-cp39-cp39-linux_aarch64.whl

CMD ["python", "-c", "\"import tensorflow as tf;print(tf.reduce_sum(tf.random.normal([1000, 1000])))\""]
