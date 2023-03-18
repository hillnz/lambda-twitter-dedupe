ARG APP_VERSION=0.7.4
FROM jonoh/twitter-dedupe:${APP_VERSION} AS source

FROM public.ecr.aws/lambda/python:3.9

ARG APP_VERSION

RUN echo ${APP_VERSION} >/VERSION

COPY --from=source /app ${LAMBDA_TASK_ROOT}
COPY lambda.py ${LAMBDA_TASK_ROOT}
RUN pip3 install -r ${LAMBDA_TASK_ROOT}/requirements.txt

CMD [ "lambda.invoke" ]
