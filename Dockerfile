# Copyright 2021 Michael Penhallegon 
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ghcr.io/howaboutudance/hematite/python-base:3.10 as source
WORKDIR app
COPY ./requirements.txt ./
COPY ./setup.py ./ README.md ./
RUN pip3 install -r requirements.txt
COPY ./sample_module/. ./sample_module

FROM source as test
COPY ./test ./test
COPY ./tox.ini ./ ./requirements-dev.txt ./
RUN pip3 install -r requirements-dev.txt
CMD tox -e py38 && mypy sample_module/

FROM source as builder
RUN pip3 install wheel
RUN python setup.py bdist_wheel

FROM ghcr.io/howaboutudance/hematite/python-base:3.10 as interact
COPY --from=builder /app/dist ./app/dist
WORKDIR app
COPY ./requirements-interact.txt ./
RUN pip3 install -r requirements-interact.txt && pip3 install dist/example_pkg_mpenhallegon*
CMD jupyter console

FROM ghcr.io/howaboutudance/hematite/python-slim:3.10 as app
COPY --from=builder /app/dist ./app/dist
WORKDIR app
RUN pip3 install dist/example_pkg_mpenhallegon*
CMD python -m sample_module