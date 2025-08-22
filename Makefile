PLENARY_INIT = tests/init.lua
TESTS_DIR = tests
ENABLED_DIR = enabled
CONTAINER_ENGINE = $(shell which podman || which docker || which false)

.PHONY: fixture test clean docs


MOCKS := ${TESTS_DIR}/fixture/cat_one/mod_one.lua ${TESTS_DIR}/fixture/cat_one/mod_two.lua ${TESTS_DIR}/fixture/cat_two/mod_three.lua ${TESTS_DIR}/fixture/cat_two/mod_four.lua

RW_MOCKS := $(subst fixture,fixture_rw,$(MOCKS))

$(MOCKS) $(RW_MOCKS):
	@mkdir -p $(@D)
	@echo -e "vim.g.confman_test_$(notdir $(@:%.lua=%)) = 1\n" > $@

WRITE_DIRS := ${TESTS_DIR}/fixture/${ENABLED_DIR} ${TESTS_DIR}/fixture_rw/${ENABLED_DIR}

$(WRITE_DIRS):
	@mkdir -p $@

fixture: $(MOCKS) $(RW_MOCKS), $(WRITE_DIRS)

test: fixture
	@nvim \
		--headless \
		--noplugin \
		-u ${PLENARY_INIT} \
		-c "PlenaryBustedDirectory ${TESTS_DIR} { minimal_init = '${PLENARY_INIT}' }"

clean:
	@rm -rf /tmp/plenary.nvim
	@rm -rf ${TESTS_DIR}/fixture
	@rm -rf ${WRITE_DIRS}

docs:
	@echo "container engine: ${CONTAINER_ENGINE}"
	@${CONTAINER_ENGINE} \
		run \
		--rm \
		-v .:/workspace \
		panvimdoc:latest \
		--project-name mod4neo-confman \
		--input-file README.md \
		--vim-version neovim-0.11 \
		--toc true \
		--demojify true \
		--dedup-subheadings true

