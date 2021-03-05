# History

vd2 data/sessions.tsv.gz
vd2 data/sessiontest.tsv.gz
ls -l data/
ls -l reports/
make partition_reports reports
ls -l
vim Makefile
less reports/sessiontest.sh
less reports/ua.sh
vd2 data/sessiontest/2020-11-scwd.ihr.world.access-sessiontest.tsv.gz
make data/sessiontest/2020-11-scwd.ihr.world.access-sessiontest.tsv.gz
vim reports/sessiontest.sh
rmdir data/ua/2020-11-scwd.ihr.world.access-sessiontest.tsv.gz
make data/ua/2020-11-scwd.ihr.world.access-sessiontest.tsv.gz
vim reports/sessions.sh
cat test.tsv | reports/sessiontest.sh
vd2  data/ua/2020-11-scwd.ihr.world.access-ua.tsv.gz
make data/ua/2020-11-scwd.ihr.world.access-ua.tsv.gz
