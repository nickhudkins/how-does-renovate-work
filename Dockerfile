FROM python:3.12-alpine@sha256:efcdfa6a6b2fd2afb9c7dfa9a5b288a6f68338b5cfdebe6b637d986067d85757

RUN apk update && apk --no-cache add gcc musl-dev openjdk17-jdk curl graphviz ttf-dejavu fontconfig

# Download plantuml file, Validate checksum & Move plantuml file
# renovate: datasource=github-releases depName=plantuml/plantuml
ARG PLANTUML_VERSION=v1.2024.6
ARG PLANTUML_CHECKSUM=3e944755cbed59e1ed9332691d92294bef7bbcda
RUN curl -o plantuml.jar -L https://github.com/plantuml/plantuml/releases/download/v${PLANTUML_VERSION}/plantuml-${PLANTUML_VERSION}.jar && echo "${PLANTUML_CHECKSUM} plantuml.jar" | sha1sum -c - && mv plantuml.jar /opt/plantuml.jar

RUN pip install --upgrade pip && pip install mkdocs-techdocs-core==1.5.4

# Create script to call plantuml.jar from a location in path
#   When adding TechDocs to the Backstage Backend container, avoid this
#   error (OSError: [Errno 8] Exec format error: 'plantuml') by using the
#   following RUN command instead:
#   RUN echo '#!/bin/sh\n\njava -jar '/opt/plantuml.jar' ${@}' >> /usr/local/bin/plantuml

#   When adding TechDocs with PlantUML diagrams, to refer external puml or pu files in any markdown file,
#   eg. '!include <referencedFileName.puml>', you'll need to include the diagrams directory eg. docs in the classpath.
#   Use following RUN command instead:
#   RUN echo $'#!/bin/sh\n\njava -Dplantuml.include.path=${diagramDir} -jar '/opt/plantuml.jar ' ${@}' >> /usr/local/bin/plantuml
RUN echo $'#!/bin/sh\n\njava -jar '/opt/plantuml.jar' ${@}' >> /usr/local/bin/plantuml
RUN chmod 755 /usr/local/bin/plantuml

ENTRYPOINT [ "mkdocs" ]