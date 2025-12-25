#/bin/sh

set -e

MYNAME='torro'
MYGROUP=${MYNAME}
TORRO_FRONTEND_NAME='airflow-frontend'
TORRO_BACKEND_NAME='airflow-backend'
TORRO_AIRFLOW_NAME='airflow-airflow'
TORRO_FRONTEND_IMAGE='torro.ai/airflow/frontend:0.0.1'
TORRO_BACKEND_IMAGE='torro.ai/airflow/backend:0.0.1'
TORRO_AIRFLOW_IMAGE='torro.ai/airflow/airflow:0.0.1'
TORRO_AIRFLOW_PATH='/opt/torroairflow'

AIRFLOW_MOUNT_ARGS="-v ./airflow.env:/opt/airflow/.env:Z -v ./airflow.cfg:/opt/airflow/airflow.cfg:Z"


# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

docker_cmd="sudo podman"

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}


# Restart service
restart_service() {
    echo "Select service to restart:"
    echo "1) ${TORRO_FRONTEND_NAME}"
    echo "2) ${TORRO_BACKEND_NAME}"
    echo "3) ${TORRO_AIRFLOW_NAME}"
    echo -n "Enter choice (1 or 2 or 3): "
    read -r choice

    case $choice in
        1)
            log_info "Restarting ${TORRO_FRONTEND_NAME}..."
            # Stop the container if it's running
            if ${docker_cmd} ps -a --format '{{.Names}}' | grep -q "^${TORRO_FRONTEND_NAME}$"; then
                ${docker_cmd} stop ${TORRO_FRONTEND_NAME} >/dev/null 2>&1 || true
                ${docker_cmd} rm ${TORRO_FRONTEND_NAME} >/dev/null 2>&1 || true
            fi
            # Start the container
            cd ${TORRO_AIRFLOW_PATH}
            ${docker_cmd} run -d --network host -v ./.env:/app/.env:Z --name ${TORRO_FRONTEND_NAME} ${TORRO_FRONTEND_IMAGE}
            log_success "${TORRO_FRONTEND_NAME} restarted successfully"
            ;;
        2)
            log_info "Restarting ${TORRO_BACKEND_NAME}..."
            # Stop the container if it's running
            if ${docker_cmd} ps -a --format '{{.Names}}' | grep -q "^${TORRO_BACKEND_NAME}$"; then
                ${docker_cmd} stop ${TORRO_BACKEND_NAME} >/dev/null 2>&1 || true
                ${docker_cmd} rm ${TORRO_BACKEND_NAME} >/dev/null 2>&1 || true
            fi
            # Start the container
            cd ${TORRO_AIRFLOW_PATH}
            ${docker_cmd} run -d --network host -v ./.env:/app/.env:Z --name ${TORRO_BACKEND_NAME} ${TORRO_BACKEND_IMAGE}
            log_success "${TORRO_BACKEND_NAME} restarted successfully"
            ;;
        3)
            log_info "Restarting ${TORRO_AIRFLOW_NAME}..."
            # Stop the container if it's running
            if ${docker_cmd} ps -a --format '{{.Names}}' | grep -q "^${TORRO_AIRFLOW_NAME}$"; then
                ${docker_cmd} stop ${TORRO_AIRFLOW_NAME} >/dev/null 2>&1 || true
                ${docker_cmd} rm ${TORRO_AIRFLOW_NAME} >/dev/null 2>&1 || true
            fi
            # Start the container
            cd ${TORRO_AIRFLOW_PATH}
            ${docker_cmd} run -d --network host ${AIRFLOW_MOUNT_ARGS} --entrypoint "" --name ${TORRO_AIRFLOW_NAME} ${TORRO_AIRFLOW_IMAGE} bash -c "airflow db migrate && airflow webserver --port 8080"
            log_success "${TORRO_AIRFLOW_NAME} restarted successfully"
            ;;
        *)
            log_error "Invalid choice. Please enter 1 or 2."
            return 1
            ;;
    esac
}

# Stop service
stop_service() {
    echo "Select service to stop:"
    echo "1) ${TORRO_FRONTEND_NAME}"
    echo "2) ${TORRO_BACKEND_NAME}"
    echo "3) ${TORRO_AIRFLOW_NAME}"
    echo -n "Enter choice (1 or 2 or 3): "
    read -r choice

    case $choice in
        1)
            log_info "Stopping ${TORRO_FRONTEND_NAME}..."
            if ${docker_cmd} ps --format '{{.Names}}' | grep -q "^${TORRO_FRONTEND_NAME}$"; then
                ${docker_cmd} stop ${TORRO_FRONTEND_NAME} >/dev/null 2>&1
                log_success "${TORRO_FRONTEND_NAME} stopped successfully"
            else
                log_warning "${TORRO_FRONTEND_NAME} is not running"
            fi
            ;;
        2)
            log_info "Stopping ${TORRO_BACKEND_NAME}..."
            if ${docker_cmd} ps --format '{{.Names}}' | grep -q "^${TORRO_BACKEND_NAME}$"; then
                ${docker_cmd} stop ${TORRO_BACKEND_NAME} >/dev/null 2>&1
                log_success "${TORRO_BACKEND_NAME} stopped successfully"
            else
                log_warning "${TORRO_BACKEND_NAME} is not running"
            fi
            ;;
        3)
            log_info "Stopping ${TORRO_AIRFLOW_NAME}..."
            if ${docker_cmd} ps --format '{{.Names}}' | grep -q "^${TORRO_AIRFLOW_NAME}$"; then
                ${docker_cmd} stop ${TORRO_AIRFLOW_NAME} >/dev/null 2>&1
                log_success "${TORRO_AIRFLOW_NAME} stopped successfully"
            else
                log_warning "${TORRO_AIRFLOW_NAME} is not running"
            fi
            ;;
        *)
            log_error "Invalid choice. Please enter 1 or 2."
            return 1
            ;;
    esac
}

# Show service status
status_service() {
    log_info "Docker containers status:"
    ${docker_cmd} ps | grep airflow
}

# Load Docker image from tar file
load_image() {
    log_info "Loading Docker image from tar file..."

    # Prompt user for tar file path
    echo -n "Please enter the path to the tar file: "
    read -r tar_file

    tar_file="$tar_file"
    # Check if file exists
    if [ ! -f "$tar_file" ]; then
        log_error "File not found: $tar_file"
        return 1
    fi

    # Check if file has .tar extension
    if [[ "$tar_file" != *.tar ]]; then
        log_warning "File does not have .tar extension. Are you sure this is a valid Docker image tar file?"
        echo -n "Continue? (y/N): "
        read -r confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            log_info "Operation cancelled by user"
            return 0
        fi
    fi

    # Load the Docker image
    log_info "Loading image from $tar_file..."
    if ${docker_cmd} load -i "$tar_file"; then
        log_success "Docker image loaded successfully from $tar_file"
    else
        log_error "Failed to load Docker image from $tar_file"
        return 1
    fi
}

airflow_db_init() {
    log_info "=== Airflow Database Initialization ==="
    log_info "This operation will initialize the Airflow database."
    log_warning "WARNING: If the database already exists, this may cause issues."

    # Prompt for confirmation
    read -p "Do you want to proceed with database initialization? (yes/no): " user_input

    case $user_input in
        "yes")
            echo "Initializing Airflow database..."
            cd ${TORRO_AIRFLOW_PATH}
            ${docker_cmd} run --rm ${AIRFLOW_MOUNT_ARGS} --entrypoint "" ${TORRO_AIRFLOW_IMAGE} airflow db migrate
            ${docker_cmd} run --rm ${AIRFLOW_MOUNT_ARGS} --entrypoint "" ${TORRO_AIRFLOW_IMAGE} airflow users create --username airflow --firstname Admin --lastname User --role Admin --email admin@example.com --password airflow
            if [ $? -eq 0 ]; then
                log_info "Database initialization completed successfully."
            else
                log_error "Database initialization failed. Please check the error messages above."
                exit 1
            fi
            ;;
        "no" | "n")
            echo "Database initialization skipped."
            ;;
        *)
            echo "Invalid input. Please enter 'yes' or 'no'."
            exit 1
            ;;
    esac
}


# Show help information
show_help() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  restart    Restart torro services"
    echo "  status     Show docker containers status"
    echo "  stop       Stop torro services"
    echo "  load       Load Docker image from tar file"
    echo "  init       Initialize the Airflow database"
    echo "  help       Show this help information"
    echo ""
}


# Main program entry
main() {
    case "$1" in
        restart)
            restart_service
            ;;
        status)
            status_service
            ;;
        stop)
            stop_service
            ;;
        load)
            load_image
            ;;
        init)
            airflow_db_init
            ;;
        help|--help|-h)
            show_help
            ;;
        "")
            log_error "Missing argument"
            show_help
            exit 1
            ;;
        *)
            log_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}


# Execute main program
main "$@"