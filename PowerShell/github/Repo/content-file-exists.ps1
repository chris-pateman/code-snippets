function fileExists($filePath, $fileName) {
  $fullPath="$filePath/$fileName"
  $file=$(gh api -H "Accept: application/vnd.github+json" /repos/$org/$repoName/contents/$fullPath | ConvertFrom-Json)
  
  return $(!($file.message -eq "Not Found"))
}
