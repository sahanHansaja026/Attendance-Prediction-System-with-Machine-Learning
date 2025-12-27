import React, { useState } from "react";
import axios from "axios";
import "../../css/courses.css";
import API_BASE_URL from "../../../config/ipconfig";

function AddCourseDetails() {
    const [courseName, setCourseName] = useState("");
    const [courseIndex, setCourseIndex] = useState("");
    const [owner, setOwner] = useState("");
    const [credits, setCredits] = useState("");
    const [category, setCategory] = useState("");
    const [relatedSkills, setRelatedSkills] = useState("");

    const [loading, setLoading] = useState(false);


    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);

        try {
            await axios.post(`${API_BASE_URL}/courses`, {
                course_name: courseName,
                courseindex: courseIndex,
                owner: owner,
                credits: Number(credits),
                category: category,
                related_skills: relatedSkills
            });

            alert("Course Added Successfully!");

            // Reset form
            setCourseName("");
            setCourseIndex("");
            setOwner("");
            setCredits("");
            setCategory("");
            setRelatedSkills("");

        } catch (error) {
            console.error(error);
            alert("Failed to add course");
        } finally {
            setLoading(false);
        }
    };


    return (
        <div className="coursepage">
            <form className="courseform" onSubmit={handleSubmit}>
                <div className="inputcontainer1">
                    <label className="label1">Module ID</label>
                    <input
                        type="text"
                        placeholder="CAT2 XXXX"
                        value={courseIndex}
                        onChange={(e) => setCourseIndex(e.target.value)}
                        required
                    />
                </div>

                <div className="inputcontainer1">
                    <label className="label1">Module Name</label>
                    <input
                        type="text"
                        placeholder="Module Name"
                        value={courseName}
                        onChange={(e) => setCourseName(e.target.value)}
                        required
                    />
                </div>

                <div className="inputcontainer1">
                    <label className="label1">Module Owner</label>
                    <input
                        type="text"
                        placeholder="Dr./Mr./Ms. ..."
                        value={owner}
                        onChange={(e) => setOwner(e.target.value)}
                        required
                    />
                </div>

                <div className="inputcontainer1">
                    <label className="label1">Credits</label>
                    <input
                        type="number"
                        placeholder="3"
                        value={credits}
                        onChange={(e) => setCredits(e.target.value)}
                        required
                    />
                </div>

                <div className="inputcontainer1">
                    <label className="label1">Category</label>
                    <select
                        value={category}
                        onChange={(e) => setCategory(e.target.value)}
                        required
                    >
                        <option value="">Select Category</option>
                        <option value="Programming">Programming</option>
                        <option value="Mathematics">Mathematics</option>
                        <option value="Data Science">Data Science</option>
                        <option value="Software Engineering">Software Engineering</option>
                    </select>
                </div>

                <div className="inputcontainer1">
                    <label className="label1">Related Skills</label>
                    <input
                        type="text"
                        placeholder="e.g., Python, React"
                        value={relatedSkills}
                        onChange={(e) => setRelatedSkills(e.target.value)}
                    />
                </div>

                <button
                    type="submit"
                    className="submit-btn"
                    disabled={loading}
                >
                    {loading ? "Adding..." : "Add Module"}
                </button>

            </form>
        </div>
    );
}

export default AddCourseDetails;
