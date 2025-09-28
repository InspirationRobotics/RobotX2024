# perception_core

The `perception_core` module manages multiple camera feeds, enables recording, and integrates inference models into the video stream.  
It provides a clean interface for the **Mission Handler** to control camera operations and retrieve results.

## Instalation
Navigate into `perception` directory and run:
```pip3 install -e .```


## Dependencies:
### Upstream
Logger: `RX24-COMMS/comms_core/logger.py`  
Camera: `RX24-perception/camera/camera_core/camera.py`  
Image: `RX24-perception/camera/camera_core/camera.py`  
Results: **TODO**

### Downstream
Mission Handler: `RX24-GNC/mission/mission_core/mission.py`

## Classes

### CameraData

Encapsulates the latest frame and inference results from a given camera.  

#### Attributes
- `timestamp (float)` – Time when the data was captured.
- `frame (np.ndarray | None)` – Latest frame from the camera, expires after 2 seconds.
- `results (Results | None)` – Inference results, expire after 2 seconds.

#### Methods
- `__init__(self, image: Image, results: Results)`  
  Stores the frame and results with a timestamp.
- `__getattr__(self, attr)`  
  Ensures `frame` and `results` are only valid for 2 seconds; returns `None` if expired.

---

### Perception

The core class responsible for managing cameras, inference, recording, and communication with the mission handler.  
It runs a background thread that continuously updates frames and results.

#### Attributes
- `camera_addrs (dict[str, list[int]])` – Bus addresses for available cameras:
  - `"port": [1, 4]`
  - `"center": [1, 10]`
  - `"starboard": [1, 11]`
- `active_cameras (dict[str, Camera])` – Currently active camera objects.
- `active_writers (dict[str, cv2.VideoWriter])` – Writers for active recordings.
- `latest_data (dict[str, CameraData])` – Latest frames and results per camera.
- `active (bool)` – Flag to keep the perception loop running.
- `change_lock (Lock)` – Ensures thread-safe modifications.
- `perception_thread (Thread)` – Runs `__perception_loop`.

#### Lifecycle
- `__init__(self)`  
  Initializes state, starts background perception thread.
- `__del__(self)`  
  Stops perception loop and cleans up all active cameras and writers.

#### Private Methods
- `__start_camera(camera_name: str)`  
  Starts a camera if not already active.
- `__stop_camera(camera_name: str)`  
  Stops a camera, releasing any associated writer.
- `__record_camera(camera_name: str)`  
  Starts recording a camera feed (`.avi` file, H.264).
- `__stop_record_camera(camera_name: str)`  
  Stops recording and releases the writer.
- `__load_model(camera_name: str, model_path: str)`  
  Loads and starts a model on the specified camera.
- `__stop_model(camera_name: str)`  
  Stops the model on the specified camera.
- `__perception_loop()`  
  Background loop: fetches frames, updates results, writes recordings.

#### Public Methods
- `_start_cameras(camera_names: list)`  
  Starts one or multiple cameras. `"all"` starts every available camera.
- `_stop_cameras(camera_names: list)`  
  Stops one or multiple cameras. `"all"` stops every active camera.
- `_record_cameras(camera_names: list)`  
  Starts recording feeds. `"all"` records all active cameras.
- `_stop_record_cameras(camera_names: list)`  
  Stops recordings. `"all"` stops all.
- `_load_models(camera_model_pairs: List[Tuple[str, str]])`  
  Loads models for one or multiple cameras. `"all"` applies to every camera.
- `_stop_models(camera_names: list)`  
  Stops models on the given cameras. `"all"` stops all.
- `get_latest_data() -> Dict[str, CameraData]`  
  Returns latest frames and inference results.
- `command_perception(commands: Dict[str, list])`  
  Central entry point for mission handler commands.

---

## Command Interface

The `command_perception` function accepts a dictionary where keys are commands and values are arguments:

```python
commands = {
    "start": ["port"],
    "stop": ["center"],
    "record": ["all"],
    "stop_record": ["starboard"],
    "load_model": [("port", "models/detector.onnx")],
    "stop_model": ["all"]
}

