INSTALL_PATH := $(HOME)
BASHRC_PATH := $(HOME)/.bashrc
BASHRC_INSTALL_LINE := source $(INSTALL_PATH)/.bash_profile_switcher
BASHRC_CHECK_INSTALL := $(findstring $(BASHRC_INSTALL_LINE),$(file < $(BASHRC_PATH)))
SNIPPETS := $(wildcard snippets/*.sh)
PROFILE_DIRECTORY := $(HOME)/.bash_profile.d
SNIPPETS_DIRECTORY := $(PROFILE_DIRECTORY)/snippets
PACKAGE_NAME := bash-profile-switcher
PACKAGE_FILES := README.md Makefile bash_profile_switcher.sh snippets .version get-version.sh
REF_TYPE := $(GITHUB_REF_TYPE)
VERSION := $(shell ./get-version.sh)

ifeq  ("$(BASHRC_CHECK_INSTALL)","$(BASHRC_INSTALL_LINE)")
	BASHRC_INSTALL_STATUS := 0
else
	BASHRC_INSTALL_STATUS := 1
endif

.PHONY: test
test:
	echo "Checking shell format..."
	docker run --rm -v "$(PWD)/bash_profile_switcher.sh:/tmp/bash_profile_switcher.sh:ro" mvdan/shfmt:v3 -d -i 4 /tmp/bash_profile_switcher.sh
	echo "Analyze with shellcheck..."
	shellcheck bash_profile_switcher.sh
	docker pull bash:5
	./tests/automated_tests.exp

.PHONY: format
format:
	shfmt -w -i 4 *.sh
	shfmt -w -i 4 snippets/*.sh

.PHONY: clean
clean:
	docker compose down
	rm -f $(PACKAGE_NAME)_*.tar.gz
	rm -f .version

.PHONY: install
install:
	install -d -m 0755 $(PROFILE_DIRECTORY)
ifneq ("$(wildcard .version)","")
	install -m 0644 -C .version $(PROFILE_DIRECTORY)/.version
endif
	install -m 0644 -C bash_profile_switcher.sh $(INSTALL_PATH)/.bash_profile_switcher
ifneq ("$(BASHRC_INSTALL_STATUS)","0")
	$(file >> $(BASHRC_PATH),$())
	$(file >> $(BASHRC_PATH),$(BASHRC_INSTALL_LINE))
endif

.PHONY: install-snippets
install-snippets: install
	install -d -m 0755 $(SNIPPETS_DIRECTORY)
	for snip in $(SNIPPETS); do \
		install -m 0755 -C $$snip $(SNIPPETS_DIRECTORY); \
	done

.PHONY: .version
.version:
	echo 'export SWITCH_PROFILE_VERSION=$(VERSION)' > .version

.PHONY: release
release: $(PACKAGE_FILES)
	tar --transform='s,,$(PACKAGE_NAME)_$(VERSION)/,' -czf $(PACKAGE_NAME)_$(VERSION).tar.gz $(PACKAGE_FILES)
