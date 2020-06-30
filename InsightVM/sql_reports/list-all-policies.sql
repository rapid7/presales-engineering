# Written 6/30/2020 by Tim H
# lists all the built-in policies on a console
# References: https://insightvm.help.rapid7.com/docs/understanding-the-reporting-data-model-dimensions

select title, description, category, benchmark_name, benchmark_version from dim_policy
where scope='Built-in'
order by title, benchmark_version
