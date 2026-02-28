using System;
using System.Collections.Generic;
using System.Linq;
using WorkHoursTimer.Models;

namespace WorkHoursTimer.Services
{
    /// <summary>
    /// 项目管理服务
    /// </summary>
    public class ProjectService
    {
        private static ProjectService? _instance;
        public static ProjectService Instance => _instance ??= new ProjectService();

        /// <summary>
        /// 项目变更事件
        /// </summary>
        public event EventHandler<ProjectChangedEventArgs>? ProjectChanged;

        /// <summary>
        /// 当前选中的项目
        /// </summary>
        public Project? CurrentProject { get; private set; }

        private ProjectService()
        {
            // 初始化时加载当前项目
            LoadCurrentProject();
        }

        /// <summary>
        /// 加载当前项目
        /// </summary>
        private void LoadCurrentProject()
        {
            var data = DataService.Instance.AppData;
            
            // 确保至少有一个默认项目
            if (data.Projects.Count == 0)
            {
                var defaultProject = new Project
                {
                    Name = "默认项目",
                    Color = "#FFD700",
                    Description = "默认工作项目"
                };
                data.Projects.Add(defaultProject);
                data.CurrentProjectId = defaultProject.Id;
                DataService.Instance.SaveData();
            }

            // 加载当前项目
            if (!string.IsNullOrEmpty(data.CurrentProjectId))
            {
                CurrentProject = data.Projects.FirstOrDefault(p => p.Id == data.CurrentProjectId);
            }

            // 如果没有当前项目，选择第一个
            if (CurrentProject == null && data.Projects.Count > 0)
            {
                CurrentProject = data.Projects[0];
                data.CurrentProjectId = CurrentProject.Id;
                DataService.Instance.SaveData();
            }
        }

        /// <summary>
        /// 获取所有项目
        /// </summary>
        public List<Project> GetAllProjects()
        {
            return DataService.Instance.AppData.Projects;
        }

        /// <summary>
        /// 获取激活的项目
        /// </summary>
        public List<Project> GetActiveProjects()
        {
            return DataService.Instance.AppData.Projects
                .Where(p => p.IsActive)
                .ToList();
        }

        /// <summary>
        /// 根据 ID 获取项目
        /// </summary>
        public Project? GetProjectById(string id)
        {
            return DataService.Instance.AppData.Projects
                .FirstOrDefault(p => p.Id == id);
        }

        /// <summary>
        /// 创建新项目
        /// </summary>
        public Project CreateProject(string name, string color = "#FFD700", string description = "")
        {
            var project = new Project
            {
                Name = name,
                Color = color,
                Description = description,
                CreatedAt = DateTime.Now,
                IsActive = true
            };

            DataService.Instance.AppData.Projects.Add(project);
            DataService.Instance.SaveData();

            // 触发项目变更事件
            ProjectChanged?.Invoke(this, new ProjectChangedEventArgs
            {
                Action = ProjectAction.Created,
                Project = project
            });

            return project;
        }

        /// <summary>
        /// 更新项目
        /// </summary>
        public bool UpdateProject(string id, string? name = null, string? color = null, string? description = null, bool? isActive = null)
        {
            var project = GetProjectById(id);
            if (project == null) return false;

            if (name != null) project.Name = name;
            if (color != null) project.Color = color;
            if (description != null) project.Description = description;
            if (isActive.HasValue) project.IsActive = isActive.Value;

            DataService.Instance.SaveData();

            // 触发项目变更事件
            ProjectChanged?.Invoke(this, new ProjectChangedEventArgs
            {
                Action = ProjectAction.Updated,
                Project = project
            });

            return true;
        }

        /// <summary>
        /// 删除项目
        /// </summary>
        public bool DeleteProject(string id)
        {
            var project = GetProjectById(id);
            if (project == null) return false;

            // 不能删除最后一个项目
            if (DataService.Instance.AppData.Projects.Count <= 1)
            {
                return false;
            }

            // 如果删除的是当前项目，切换到第一个其他项目
            if (CurrentProject?.Id == id)
            {
                var otherProject = DataService.Instance.AppData.Projects
                    .FirstOrDefault(p => p.Id != id);
                if (otherProject != null)
                {
                    SwitchProject(otherProject.Id);
                }
            }

            DataService.Instance.AppData.Projects.Remove(project);
            DataService.Instance.SaveData();

            // 触发项目变更事件
            ProjectChanged?.Invoke(this, new ProjectChangedEventArgs
            {
                Action = ProjectAction.Deleted,
                Project = project
            });

            return true;
        }

        /// <summary>
        /// 切换当前项目
        /// </summary>
        public bool SwitchProject(string id)
        {
            var project = GetProjectById(id);
            if (project == null || !project.IsActive) return false;

            CurrentProject = project;
            DataService.Instance.AppData.CurrentProjectId = id;
            DataService.Instance.SaveData();

            // 触发项目变更事件
            ProjectChanged?.Invoke(this, new ProjectChangedEventArgs
            {
                Action = ProjectAction.Switched,
                Project = project
            });

            return true;
        }

        /// <summary>
        /// 更新项目统计
        /// </summary>
        public void UpdateProjectStats(string projectId, int durationSeconds)
        {
            var project = GetProjectById(projectId);
            if (project == null) return;

            project.TotalSeconds += durationSeconds;
            project.SessionCount++;
            DataService.Instance.SaveData();
        }

        /// <summary>
        /// 获取项目统计
        /// </summary>
        public ProjectStats GetProjectStats(string projectId)
        {
            var project = GetProjectById(projectId);
            if (project == null)
            {
                return new ProjectStats();
            }

            var sessions = DataService.Instance.AppData.Sessions
                .Where(s => s.ProjectName == project.Name)
                .ToList();

            return new ProjectStats
            {
                ProjectId = project.Id,
                ProjectName = project.Name,
                TotalSeconds = project.TotalSeconds,
                SessionCount = project.SessionCount,
                TotalHours = project.TotalHours,
                FormattedTotalTime = project.FormattedTotalTime,
                LastSessionDate = sessions.Any() ? sessions.Max(s => s.StartTime) : null
            };
        }
    }

    /// <summary>
    /// 项目变更事件参数
    /// </summary>
    public class ProjectChangedEventArgs : EventArgs
    {
        public ProjectAction Action { get; set; }
        public Project? Project { get; set; }
    }

    /// <summary>
    /// 项目操作类型
    /// </summary>
    public enum ProjectAction
    {
        Created,
        Updated,
        Deleted,
        Switched
    }

    /// <summary>
    /// 项目统计信息
    /// </summary>
    public class ProjectStats
    {
        public string ProjectId { get; set; } = string.Empty;
        public string ProjectName { get; set; } = string.Empty;
        public int TotalSeconds { get; set; }
        public int SessionCount { get; set; }
        public double TotalHours { get; set; }
        public string FormattedTotalTime { get; set; } = "0h 0m";
        public DateTime? LastSessionDate { get; set; }
    }
}
