desc 'Create development environment'
task :bootstrap do
  system("brew install ffmpeg")
  system("brew install qtfaststart")
  Rake::Task['db:bootstrap'].invoke
  system("ln -sf ../../misc/post-pull.sh .git/hooks/post-merge")
  system("ln -sf ../../misc/pre-commit.sh .git/hooks/pre-commit")
end
