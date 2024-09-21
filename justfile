# don't clear screens after tests, regardless of current environment
unexport UTR_CLEAR_PRE_RUN

_default:
    just --list

# error out if this isn't being run in a venv
_require-venv:
    #!/usr/bin/env python
    import sys
    sys.exit(sys.prefix == sys.base_prefix)

@lint:
    ruff check --quiet .
    ruff format --check --quiet .

# lint&fix files, useful for a pre-commit hook
@lint-fix:
    ruff check --fix --quiet .
    ruff format --quiet .

@typecheck:
    pyright -p pyproject.toml

# perform all checks, but don't change any files
@validate: lint typecheck

# useful for install after changing dependencies
@install: _require-venv
    pip install -e .[ci]

@release: _require-venv validate
    rm -rf dist
    pip install -e .[release]
    python -m build
    # give upload api key at runtime
    python -m twine upload --username __token__ dist/*
