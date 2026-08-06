# Private Linux Launch

From the project folder:

```bash
chmod +x run_live_private.sh
./run_live_private.sh
```

The first launch asks for the Twelve Data key without displaying it on screen. The key is saved locally at:

```text
~/.config/titan_ai/twelve_data_key
```

Permissions are restricted to the Linux user.

To replace the key:

```bash
rm ~/.config/titan_ai/twelve_data_key
./run_live_private.sh
```
