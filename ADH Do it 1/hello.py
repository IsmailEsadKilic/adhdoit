

class Schedule:
    start: str
    end: str

class Block:
    name: str
    description: str
    interruption: bool
    template: bool
    schedule: Schedule

class Day:
    index: int
    blocks: list[Block]

class Week:
    template: bool
    name: str
    days: list[Day]

class scheduler():
    y2023: str
    
    def hi():
        print("hi")