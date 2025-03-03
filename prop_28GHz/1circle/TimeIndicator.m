classdef TimeIndicator < handle
   properties
      disp_est_time {mustBeNumeric}
      start_time
      start_p {mustBeNumeric}
      filename
      call_counter
      call_total
      call_counter_inner
      call_total_inner
   end

   methods
      function obj = TimeIndicator(filename, call_total)
        obj.filename = filename;
        obj.call_counter = 0;
        obj.call_total = call_total;
      end

      function add_call_counter(obj) 
        obj.call_counter = obj.call_counter + 1;
      end

      function start(obj)
        obj.start_time = datetime;
        obj.start_p = posixtime(obj.start_time);
        tic;
      end

      function dt = elapsed_time(obj)
        dt = between(obj.start_time, datetime('now'));
      end

      function init_inner(obj, call_total_inner)
        obj.call_counter_inner = 0;
        obj.call_total_inner = call_total_inner;
      end

      function add_call_counter_inner(obj)
        obj.call_counter_inner = obj.call_counter_inner + 1;
      end

      function lap(obj, show)
        if ~exist("show", "var")
          show = 1;
        end
        obj.add_call_counter();
        progress = obj.call_counter / obj.call_total * 100;
        if show
          obj.lap_(progress)
        end
      end

      function lap_inner(obj)
        obj.add_call_counter_inner();
        inner_prog = obj.call_counter_inner / obj.call_total_inner;
        outer_prog = obj.call_counter / obj.call_total;
        progress = (outer_prog + inner_prog / obj.call_total) * 100;
        obj.lap_(progress);
      end

      function lap_(obj, progress)
        fprintf('%s:\n', obj.filename);
        fprintf('\tcompleted:    %3.2f%% ', progress);
        max_num = 30;
        num_sharp = floor(max_num / 100.0 * progress);
        sharps = repmat('#', 1, num_sharp);
        dots = repmat('.', 1, max_num - num_sharp);
        fprintf('\t[%s%s]\n', sharps, dots);
        fprintf('\telapsed time: %s\n', string(obj.elapsed_time));
        elapsed_time = toc;
        est_time = elapsed_time * (100 / progress);
        est_fin_time = datetime(obj.start_p + est_time, 'ConvertFrom', 'posixtime');
        fprintf('\test fin time: %s\n', string(est_fin_time));
        fprintf('\tcurrent time: %s\n\n', string(datetime));
      end
   end
end

%{
**USAGE**:
iter = 10;
time_indicator = TimeIndicator("test", iter);
time_indicator.start();

for i = 1:iter
  test_func(time_indicator)
  time_indicator.lap();
end

function test_func(time_indicator)
  iiter = 10;
  time_indicator.init_inner(iiter);
  for i=1:iiter
    pause(0.5)
    time_indicator.lap_inner();
  end
end
%}
