# Project short scripts

.PHONY: generate
generate:
	flutter pub run build_runner build --delete-conflicting-outputs 
	
.PHONY: formatSort
sort:
	flutter format lib/ && \
	flutter format test/ && \
	flutter pub run import_sorter:main

.PHONY: buildReleaseArtefacts
release:
	flutter build apk && flutter build appbundle && eytool -printcert -jarfile /home/adan/Projects/live/shamiri/xplore/build/app/outputs/bundle/release/app-release.aab