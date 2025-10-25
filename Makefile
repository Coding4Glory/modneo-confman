PLENARY_INIT = tests/init.lua
TESTS_DIR = tests
FIXTURE_DIR = $(TESTS_DIR)/fixture
ENABLED_DIR = enabled
CONTAINER_ENGINE = $(shell which podman || which docker || which false)

.PHONY: fixture test clean docs


MOCKS := ${FIXTURE_DIR}/ro/cat_one/mod_one.lua ${FIXTURE_DIR}/ro/cat_one/mod_two.lua ${FIXTURE_DIR}/ro/cat_two/mod_three.lua ${FIXTURE_DIR}/ro/cat_two/mod_four.lua

RW_MOCKS := $(subst ro,rw,$(MOCKS))
REN_MOCKS := $(addsuffix .off,$(subst ro,rename,$(MOCKS)))
LINK_MOCKS := $(subst ro,link,$(MOCKS))
MIGRATE_MOCKS := $(subst ro,migrate,$(MOCKS))


$(MOCKS) $(RW_MOCKS) $(REN_MOCKS) $(LINK_MOCKS) $(MIGRATE_MOCKS):
	@mkdir -p $(@D)
	@echo -e "vim.g.confman_test_$(notdir $(@:%.lua=%)) = 1\n" > $@

WRITE_DIRS := $(FIXTURE_DIR)/ro/$(ENABLED_DIR) $(FIXTURE_DIR)/rw/$(ENABLED_DIR) $(FIXTURE_DIR)/rename/$(ENABLED_DIR) $(FIXTURE_DIR)/link/$(ENABLED_DIR) ${FIXTURE_DIR}/migrate/${ENABLED_DIR}

$(WRITE_DIRS):
	@mkdir -p $@

fixture: $(MOCKS) $(RW_MOCKS) $(REN_MOCKS) $(LINK_MOCKS) $(WRITE_DIRS) ${MIGRATE_MOCKS}
	@mv $(FIXTURE_DIR)/rename/cat_two/mod_three.lua.off $(FIXTURE_DIR)/rename/cat_two/mod_three.lua
	@ln -s ../cat_one/mod_one.lua ${FIXTURE_DIR}/migrate/enabled/cat_one-mod_one.lua
	@ln -s ../cat_one/mod_two.lua ${FIXTURE_DIR}/migrate/enabled/cat_one-mod_two.lua

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
		--project-name modneo-confman \
		--input-file README.md \
		--vim-version neovim-0.11 \
		--toc true \
		--demojify true \
		--dedup-subheadings true

