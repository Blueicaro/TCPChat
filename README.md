# TCPChat
Just a very simple multi client chat server. You make a connection via tcp(like with telnet or ncat) and chat away! This project is to just serve as an example for newbie freepascal/pascal developers on how to implement a multi client and multi threaded chat server. The key focus being multi client and multi threaded and how to keep track of clients and access each client.

# Usage
Just run the program! For now the server just binds 0.0.0.0 and listens on port 1234. There are no command line parameters. You have to modify the code and then recompile. Once connected, you will get a random username. Send ```/nick <username>``` to change your username. Currently it does not check if other users have that username, but this is supposed to be an example of a multi client chat server, so i want to keep it as simple as possible.

# Compiling

## Compile requirements
You need the freepascal compiler(FPC) and the [synapse networking library](http://synapse.ararat.cz/doku.php). The lazarus ide is optional but recommended.

## Building
If you use lazarus then just open up the project and compile!

If you use just FPC then do the following
1. Make sure FPC knows where the syanpse library is by either putting it in your fpc.cfg or just coping the library source to you build directory or by passing the right command line parameters.
2. Rename(or make a copy of) multiclientserver.lpr to multiclientserver.pas.
3. Run the following command ```fpc -MObjPas multiclientserver.pas```
4. Now you can test out the server!

# Supported platforms
This server was tested on linux mint 20 and works fine! This will probably not work on windows. The reason being that the way it checks for disconnections. It reads the last error that syanpse reports and synapse reports the error code that the underlying socket library of the platform reports. I only implemented linux's error but not windows's or any other platform.

# TODO
- [ ] Make it configurable via config file or cli parameters.
- [ ] Make it cross platform
- [ ] Maybe add more commands.
- [ ] Add ssl support, configurable via cli parameter or config file(like ssl certs and keys)
- [ ] Add comments, seeing as this is ment for beginners to learn from
