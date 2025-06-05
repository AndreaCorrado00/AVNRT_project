function trace_envelope=get_envelope(trace,N,method)
[trace_envelope, ~] = envelope(trace, N,method);  % Compute the envelope, fixed evaluation