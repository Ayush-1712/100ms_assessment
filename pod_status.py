import os

#Runs a simple kubectl command and returns the output
def run_kubectl_command(command):
    print(f"Running command: {command}")
    try:
        result = os.popen(command).read()
        if not result:
            print(f"Error: No output returned from command '{command}'")
            return None
        print(f"Command output: {result[:200]}...")  
        return result
    except Exception as e:
        print(f"Error executing command: {e}")
        return None

#Get a list of pods
def get_pods():
    command = "kubectl get pods --all-namespaces --no-headers"
    output = run_kubectl_command(command)
    if not output:
        print("No pods found or error in fetching pods.")
        return []
    pods = []
    for line in output.strip().split("\n"):
        parts = line.split()
        namespace = parts[0]
        pod_name = parts[1]
        pod_status = parts[3]
        pods.append((namespace, pod_name, pod_status))
    return pods

#Save the logs of the pod in pending state
def save_pod_logs(namespace, pod_name):
    command = f"kubectl logs {pod_name} -n {namespace}"
    logs = run_kubectl_command(command)
    if logs:
        log_file = f"{pod_name}-logs.txt"
        with open(log_file, "w") as file:
            file.write(logs)
        print(f"Logs for pod '{pod_name}' in namespace '{namespace}' saved to '{log_file}'.")
    else:
        print(f"Error: Could not fetch logs for pod '{pod_name}'.")

def main():
    # Step 1: Get all pods across all namespaces
    print("Fetching pods in all namespaces...")
    pods = get_pods()
    
    if not pods:
        print("No pods found in the cluster.")
        return
    
    print("Pods in the cluster:")
    for namespace, pod_name, pod_status in pods:
        print(f"  - Namespace: {namespace} | Pod: {pod_name} (Status: {pod_status})")
    
    # Step 2: Check and fetch logs for pods that are not running
    for namespace, pod_name, pod_status in pods:
        if pod_status != "Running":
            print(f"Pod '{pod_name}' in namespace '{namespace}' is not running (Status: {pod_status}). Fetching logs...")
            save_pod_logs(namespace, pod_name)

if __name__ == "__main__":
    main()
