let check_exit_status = function
	| Unix.WEXITED 0 -> true
	| Unix.WEXITED r -> Printf.eprintf "warning: the process terminated with exit code (%d)\n%!" r; false
	| Unix.WSIGNALED n -> Printf.eprintf "warning: the process was killed by a signal (number: %d)\n%!" n; false
	| Unix.WSTOPPED n -> Printf.eprintf "warning: the process was stopped by a signal (number: %d)\n%!" n; false
;;

let was_successful = function
	| Unix.WEXITED 0 -> true
	| Unix.WEXITED r -> false
	| Unix.WSIGNALED n -> false
	| Unix.WSTOPPED n -> false

let syscall : ?env:string array -> string -> string * string * Unix.process_status = fun ?(env=[| |]) cmd ->
	print_endline cmd;
	let ic, oc, ec = Unix.open_process_full cmd env in
	let buf1 = Buffer.create 96
	and buf2 = Buffer.create 48 in
	(try while true do Buffer.add_channel buf1 ic 1 done
	with End_of_file -> ());
	(try while true do Buffer.add_channel buf2 ec 1 done
	with End_of_file -> ());
	let exit_status = Unix.close_process_full (ic, oc, ec) in
	check_exit_status exit_status;
	(Buffer.contents buf1,
	Buffer.contents buf2,
	exit_status)
